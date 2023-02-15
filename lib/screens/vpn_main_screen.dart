import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ghost_vpn_ios/bloc/vpn_bloc/vpn_bloc.dart';
import 'package:ghost_vpn_ios/bloc/vpn_bloc/vpn_event.dart';
import 'package:ghost_vpn_ios/bloc/vpn_bloc/vpn_state.dart';
import 'package:ghost_vpn_ios/config/utils.dart';
import 'package:ghost_vpn_ios/screens/authentication_screens/wrapper_screen.dart';
import 'package:ghost_vpn_ios/screens/services_screens/expiration_screen.dart';
import 'package:ghost_vpn_ios/services/firebase_api_services.dart';
import 'package:ghost_vpn_ios/widgets/container_speed_widget.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';

class VpnMainScreen extends StatefulWidget {
  const VpnMainScreen({Key? key}) : super(key: key);

  @override
  State<VpnMainScreen> createState() => _VpnMainScreenState();
}

class _VpnMainScreenState extends State<VpnMainScreen> {
  final auth = FirebaseApiServices();
  bool isConnected = false;

  late OpenVPN openvpn;
  late VpnStatus? status;
  late VPNStage stage;

  String stringStage = 'START';
  dynamic chatDocId;
  dynamic chatDocConfigId;

  Timer? timer;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  Timestamp? promoExpirationTime;
  bool isTimetoPay = false;
  CollectionReference collectionReference_configs =
      FirebaseFirestore.instance.collection('configs');

  bool isLoading = false;

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 60), (timer) async {
      checkFields();
    });
    openvpn = OpenVPN(
        onVpnStatusChanged: _onVpnStatusChanged,
        onVpnStageChanged: _onVpnStageChanged);
    openvpn.initialize(
        groupIdentifier: "group.com.ghost.vpn.ios",
        providerBundleIdentifier: "com.ghost.vpn.ios.VPNExtension",
        localizedDescription: "GhostVPN");

    super.initState();
  }

  Future checkFields() async {
    await users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        setState(() async {
          if (!mounted) return;
          promoExpirationTime = snapshot.docs.single.get('promoExpirationTime');
          isTimetoPay = await getTimeToPay(snapshot.docs.single.id);
          if (isTimetoPay) {
            timer?.cancel();
            await users.doc(snapshot.docs.single.id).update({'isPromo': '1'});
            await Navigator.push(context,
                MaterialPageRoute(builder: ((context) => ExpirationScreen())));
          }
        });
      }
    }).catchError((error) {});
  }

  Future<bool> getTimeToPay(dynamic doc) async {
    final expTime = Utils.toDateTime(promoExpirationTime);
    final isInnerTimeToPay = expTime!.isBefore(DateTime.now());
    return isInnerTimeToPay;
  }

  void _onVpnStatusChanged(VpnStatus? vpnStatus) {
    if (!mounted) return;
    setState(() {
      status = vpnStatus;
    });
  }

  void _onVpnStageChanged(VPNStage stage, String string) {
    if (!mounted) return;
    setState(() {
      this.stage = stage;
    });
    listenVpnStage(stage);
  }

  listenVpnStage(VPNStage vpnStage) async {
    switch (vpnStage.toString()) {
      case 'VPNStage.connected':
        if (!mounted) return;
        setState(() {
          isConnected = true;
          stringStage = 'СТОП';
        });
        break;
      case 'VPNStage.disconnected':
        if (!mounted) return;
        setState(() {
          isConnected = false;
          stringStage = 'СТАРТ';
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VpnBloc, VpnState>(
      listener: (context, state) async {
        if (state is VpnLoadingState) {
          if (!mounted) return;
          await EasyLoading.show(
              status: "Загрузка", maskType: EasyLoadingMaskType.black);
        }

        if (state is VpnConnectedState) {
          if (!mounted) return;
          setState(() {
            stringStage = 'СТОП';
            isConnected = true;
            chatDocConfigId = state.chatDocId;
          });
          await Future.delayed(Duration(seconds: 4)).then((_) {
            EasyLoading.showSuccess('Все прошло успешно!');
          });
        }

        if (state is VpnDisconnectedState) {
          if (!mounted) return;
          setState(() {
            stringStage = 'СТАРТ';
            isConnected = false;
          });
          DocumentReference documentReference = FirebaseFirestore.instance
              .collection('configs')
              .doc(chatDocConfigId);
          FirebaseFirestore.instance.runTransaction((transaction) async {
            final snapshot = await transaction.get(documentReference);
            final newActive = snapshot.get('active') - 1;
            await transaction.update(documentReference, {'active': newActive});
          });
        }
      },
      child: WillPopScope(
        onWillPop: () async => false,
        child: Stack(
          children: [
            Image.asset(
              'assets/icons/back_image.jpg',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                actions: [
                  IconButton(
                    onPressed: () async {
                      if (isConnected) {
                        EasyLoading.showInfo('Отключите ВПН!');
                      } else {
                        await auth.signOut();
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => Wrapper()));
                        print('User is out');
                      }
                    },
                    icon: Icon(
                      Icons.exit_to_app_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
                backgroundColor: Colors.black,
                automaticallyImplyLeading: false,
                centerTitle: true,
                leading: IconButton(
                    onPressed: () async {},
                    icon: Icon(Icons.telegram_outlined, color: Colors.white)),
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Ghost',
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              fontSize: 25),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'VPN',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Image.asset(
                          'assets/icons/icon.jpg',
                          fit: BoxFit.cover,
                          height: 30,
                          width: 30,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              body: Padding(
                padding: EdgeInsets.zero,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: () async {
                          isConnected
                              ? {
                                  BlocProvider.of<VpnBloc>(context).add(
                                      VpnDisconnect(
                                          openVPN: openvpn,
                                          chatDocId: chatDocId))
                                }
                              : {
                                  BlocProvider.of<VpnBloc>(context)
                                      .add(VpnConnect(
                                    openVPN: openvpn,
                                  ))
                                };
                        },
                        child: Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(150),
                            child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                    height: 140,
                                    width: 140,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.power_settings_new,
                                          size: 34,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          stringStage,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 23,
                                            fontWeight: FontWeight.w100,
                                          ),
                                        ),
                                      ],
                                    )))),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ContainerSpeedWidget(
                              speed: isConnected ? status!.byteIn! : "0",
                              type: 'Скачано',
                            ),
                            ContainerSpeedWidget(
                              speed: isConnected ? status!.byteOut! : "0",
                              type: 'Загружено',
                            ),
                          ],
                        ),
                      )
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
