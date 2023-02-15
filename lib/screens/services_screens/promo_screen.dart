import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_bloc.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_event.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_state.dart';
import 'package:ghost_vpn_ios/screens/vpn_main_screen.dart';
import 'package:ghost_vpn_ios/widgets/loader_widget.dart';
import 'package:ghost_vpn_ios/widgets/widget.dart';

class PromoScreen extends StatefulWidget {
  final String? email;
  const PromoScreen({Key? key, this.email}) : super(key: key);

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  CollectionReference users = FirebaseFirestore.instance.collection('test');
  dynamic chatDocId;

  bool _isLoading = false;
  String? _warning;

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  @override
  void dispose() {
    if (!mounted) return;
    _warning = null;
    super.dispose();
  }

  Future<void> checkUser() async {
    await users
        .where('email', isEqualTo: widget.email)
        .limit(1)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          chatDocId = snapshot.docs.single.id;
        });
        print('-------chatDocId: $chatDocId');
      } else {
        await users.add({'isPromo': '1'}).then((value) {
          chatDocId = value;
        });
      }
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VpnAuthBloc, VpnAuthState>(
      listener: (context, state) async {
        if (state is VpnAuthPromoDataState) {
          setState(() {
            _isLoading = false;
          });
          await Navigator.push(
              context, MaterialPageRoute(builder: (_) => VpnMainScreen()));
        }

        if (state is VpnAuthErrorState) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isLoading
            ? LoaderWidget()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ShowAlert(
                        warning: _warning,
                        function: () {
                          setState(() {
                            _warning = null;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Привет, друг. Рады привествовать тебя на нашем VPN сервисе.\tПредлагаем в качестве маленького подарка: бесплатное использование нашего сервиса на протяжение 5 дней.\n\nУдачного дня.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLoading = true;
                            });
                            BlocProvider.of<VpnAuthBloc>(context).add(
                                VpnSendPromoData(
                                    chatDocId: chatDocId, collection: users));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                              color: Colors.white,
                            ),
                            height: 70,
                            width: 300,
                            child: Center(
                                child: Text('Перейти дальше',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w300,
                                    ))),
                          ),
                        ),
                      ),
                    ]),
              ),
      ),
    );
  }
}
