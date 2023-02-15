import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:ghost_vpn_ios/config/utils.dart';
import 'package:ghost_vpn_ios/models/firestore_user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class Users {
  String? uid;
  String? name;
  String? email;

  Users({
    this.uid,
    this.name,
    this.email,
  });
}

abstract class AuthBase {
  Stream<Users> get authStateChanges;
  Future<Users> currentUser();
  Future<Users> signInWithEmailAndPassword(String email, String password);
  Future<Users> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<void> completePayment();
  Future<void> resetPasswordUsingEmail(String email);
  Future<void> signOut();
  Future<Users?> signInWithApple();
  Future<void> sendVerificationEmail();
  Future getServerConfig(String configName);
}

class FirebaseApiServices implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseStorage = FirebaseStorage.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('test');
  dynamic chatDocId;

  Users _userFromFirebase(User? user) {
    if (user == null) {
      print('There is no users with uid');
      return Users();
    } else {
      return Users(
        uid: user.uid,
        name: user.displayName,
        email: user.email,
      );
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    final user = _firebaseAuth.currentUser;
    await user!.sendEmailVerification();
  }

  @override
  Stream<Users> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  @override
  Future<Users> currentUser() async {
    final user = _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  @override
  Future<Users> signInWithEmailAndPassword(
      String email, String password) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<Users> createUserWithEmailAndPassword(
      String email, String password) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _firebaseAuth.currentUser!.reload();
    final newUser = FirestoreUser(
      idUser: _firebaseAuth.currentUser!.uid,
      email: _firebaseAuth.currentUser!.email!,
      isPromo: '-1',
      lastCreationTime: DateTime.now(),
    );
    await users.add(newUser.toMap());
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<void> resetPasswordUsingEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<Users?> signInWithApple({List<Scope> scopes = const []}) async {
    // 1. perform the sign-in request
    final result = await TheAppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email])
    ]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final authResult = await _firebaseAuth.signInWithCredential(credential);
        await users
            .where('email', isEqualTo: authResult.user!.email)
            .limit(1)
            .get()
            .then((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            chatDocId = snapshot.docs.single.id;
            print('-------chatDocId apple: $chatDocId');
          } else {
            await _firebaseAuth.currentUser!.reload();
            final newUser = FirestoreUser(
              idUser: _firebaseAuth.currentUser!.uid,
              email: appleIdCredential.email!,
              isPromo: '-1',
              lastCreationTime: DateTime.now(),
            );
            await users.add(newUser.toMap()).then((value) {
              chatDocId = value;
            });
          }
        });
        return _userFromFirebase(authResult.user);

      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR',
          message: 'Error',
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        return null;
    }
  }

  @override
  Future<void> completePayment() async {
    try {
      DateTime promoTime = DateTime.now();
      final expDay = promoTime.day + 30;
      final expMonth = promoTime.month;
      final expYear = promoTime.year;
      DateTime expTime = DateTime(expYear, expMonth, expDay);
      await users
          .where('email', isEqualTo: _firebaseAuth.currentUser!.email)
          .limit(1)
          .get()
          .then((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          chatDocId = snapshot.docs.single.id;
          await users.doc(chatDocId).update({
            'isPromo': "2",
            'promoStartedTime': Utils.fromDateTimeToJson(promoTime),
            'promoExpirationTime': Utils.fromDateTimeToJson(expTime),
          });
        }
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Future getServerConfig(String configName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${configName}.txt');
    await _firebaseStorage.ref('configs/${configName}.txt').writeToFile(file);
    return file.path;
  }
}
