import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghost_vpn_ios/bloc/vpn_bloc/vpn_event.dart';
import 'package:ghost_vpn_ios/bloc/vpn_bloc/vpn_state.dart';
import 'package:ghost_vpn_ios/models/firebase_config.dart';
import 'package:ghost_vpn_ios/services/firebase_api_services.dart';

class VpnBloc extends Bloc<VpnEvent, VpnState> {
  CollectionReference collectionReference_configs =
      FirebaseFirestore.instance.collection('configs');
  final auth = FirebaseApiServices();

  VpnBloc() : super(VpnInitialState()) {
    on<VpnSubscriptionPay>((event, emit) async {
      try {
        emit(VpnSubscriptionPaidState());
      } catch (e) {
        print(e);
        emit(VpnReturnState());
      }
    });

    on<VpnConnect>((event, emit) async {
      emit(VpnLoadingState());

      await collectionReference_configs.get().then((snapshots) async {
        List<FirebaseConfig> configs = [];
        if (snapshots.docs.isNotEmpty) {
          snapshots.docs.forEach((element) {
            configs.add(FirebaseConfig(
                name: element.get('name'), active: element.get('active')));
          });

          String configName = configs[0].name;
          int min = configs[0].active;
          for (int i = 0; i < configs.length; i++) {
            if (configs[i].active < min) {
              configName = configs[i].name;
            }
          }
          final path = await auth.getServerConfig(configName);
          final remoteConfig = await File(path).readAsString();
          print(configName);
          print(path);

          dynamic chatDocId;

          await collectionReference_configs
              .where('name', isEqualTo: configName)
              .limit(1)
              .get()
              .then((snapshot) async {
            if (snapshots.docs.isNotEmpty) {
              chatDocId = snapshot.docs.single.id;
              DocumentReference documentReference = FirebaseFirestore.instance
                  .collection('configs')
                  .doc(chatDocId);
              FirebaseFirestore.instance.runTransaction((transaction) async {
                final snapshot = await transaction.get(documentReference);
                final newActive = snapshot.get('active') + 1;
                await transaction
                    .update(documentReference, {'active': newActive});
              }).catchError((e) {
                print(e);
              });
            }
          });

          try {
            event.openVPN.connect(
              remoteConfig,
              'GhostVPN',
              username: '',
              password: '',
              bypassPackages: [],
              certIsRequired: true,
            );
            emit(VpnConnectedState(isConnected: true, chatDocId: chatDocId));
          } catch (e) {
            print(e);
            emit(VpnErrorState());
          }
        }
      });
    });

    on<VpnDisconnect>((event, emit) async {
      event.openVPN.disconnect();
      emit(VpnDisconnectedState());
    });
  }
}
