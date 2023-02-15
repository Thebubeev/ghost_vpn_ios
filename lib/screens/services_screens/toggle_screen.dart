import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ghost_vpn_ios/config/utils.dart';
import 'package:ghost_vpn_ios/screens/authentication_screens/wrapper_screen.dart';
import 'package:ghost_vpn_ios/screens/services_screens/expiration_screen.dart';
import 'package:ghost_vpn_ios/screens/services_screens/promo_screen.dart';
import 'package:ghost_vpn_ios/screens/vpn_main_screen.dart';
import 'package:ghost_vpn_ios/services/firebase_api_services.dart';
import 'package:ghost_vpn_ios/widgets/loader_widget.dart';

class ToggleScreen extends StatefulWidget {
  @override
  State<ToggleScreen> createState() => _ToggleScreenState();
}

class _ToggleScreenState extends State<ToggleScreen> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final auth = FirebaseApiServices();
  final _firebaseAuth = FirebaseAuth.instance;
  bool? isEmailVerified;
  CollectionReference users = FirebaseFirestore.instance.collection('test');

  dynamic chatDocId;
  String? email = '';

  String? isPromo = '0';
  bool isTimetoPay = false;

  Timestamp? promoExpirationTime;

  @override
  void initState() {
    super.initState();
    isEmailVerified = _firebaseAuth.currentUser?.emailVerified;
    if (isEmailVerified == null) {
      return null;
    } else if (isEmailVerified!) {
      setState(() {
        if (!mounted) return;
        email = _firebaseAuth.currentUser!.email;
      });
      checkEmailVerified();
    }
    checkFields();
  }

  Future checkFields() async {
    await users
        .where('email', isEqualTo: email)
        .limit(1)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          if (!mounted) return;
          isPromo = snapshot.docs.single.get('isPromo');
          chatDocId = snapshot.docs.single.id;
        });
      }
      if (isPromo == '1' || isPromo == '2') {
        if (!mounted) return;
        setState(() async {
          promoExpirationTime = snapshot.docs.single.get('promoExpirationTime');
          isTimetoPay = await getTimeToPay(snapshot.docs.single.id);
        });
      }
    }).catchError((error) {});
  }

  Future<bool> getTimeToPay(dynamic doc) async {
    final expTime = Utils.toDateTime(promoExpirationTime);
    final isInnerTimeToPay = expTime!.isBefore(DateTime.now());
    return isInnerTimeToPay;
  }

  Future checkEmailVerified() async {
    await _firebaseAuth.currentUser?.reload();
    setState(() {
      isEmailVerified = _firebaseAuth.currentUser?.emailVerified;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Text('Error ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final email = snapshot.data?.email;
                  if (isEmailVerified == false || isEmailVerified == null) {
                    return Wrapper();
                  } else if (isEmailVerified! &&
                      isPromo == '-1' &&
                      isTimetoPay == false) {
                    return PromoScreen(
                      email: email,
                    );
                  } else if (isTimetoPay &&
                      isEmailVerified! &&
                      isPromo == '1') {
                    return ExpirationScreen();
                  } else if (isEmailVerified! &&
                      isPromo == '2' &&
                      isTimetoPay == false) {
                    return VpnMainScreen();
                  }
                }
                return LoaderWidget();
              });
        }
        return LoaderWidget();
      },
    );
  }
}
