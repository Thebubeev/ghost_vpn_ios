import 'package:flutter/material.dart';
import 'package:ghost_vpn_ios/screens/authentication_screens/wrapper_screen.dart';
import 'package:ghost_vpn_ios/services/firebase_api_services.dart';

class ExpirationScreen extends StatefulWidget {
  const ExpirationScreen({Key? key}) : super(key: key);

  @override
  State<ExpirationScreen> createState() => _ExpirationScreenState();
}

class _ExpirationScreenState extends State<ExpirationScreen> {
  final auth = FirebaseApiServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await auth.signOut();
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Wrapper()));
              print('User is out');
            },
            icon: Icon(
              Icons.exit_to_app_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Вот и закончилась подписка. Надеюсь ты готов перейти на страницу оплаты для продления подписки.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {},
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
    );
  }
}
