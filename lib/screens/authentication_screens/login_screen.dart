import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_bloc.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_event.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_state.dart';
import 'package:ghost_vpn_ios/screens/authentication_screens/forget_screen.dart';
import 'package:ghost_vpn_ios/screens/services_screens/toggle_screen.dart';
import 'package:ghost_vpn_ios/services/firebase_api_services.dart';
import 'package:ghost_vpn_ios/widgets/loader_widget.dart';
import 'package:ghost_vpn_ios/widgets/widget.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final auth = FirebaseApiServices();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  String? _warning;
  bool _isLoading = false;

  @override
  void dispose() {
    if (!mounted) return;
    _emailController.dispose();
    _passController.dispose();
    _warning = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VpnAuthBloc, VpnAuthState>(
      listener: (context, state) async {
        if (state is VpnAuthNavigatorState) {
          setState(() {
            _isLoading = false;
          });
          await Navigator.push(
              context, MaterialPageRoute(builder: (_) => ToggleScreen()));
        }

        if (state is VpnAuthLoginToastState) {
          setState(() {
            _isLoading = false;
            _warning = 'Пожалуйста, подтвердите вашу почту.';
          });
          try {
            await auth.sendVerificationEmail();
          } catch (e) {
            print(e);
          }
        }

        if (state is VpnAuthErrorState) {
          if (state.warning ==
              '[firebase_auth/unknown] Given String is empty or null') {
            setState(() {
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
              _warning = state.warning;
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isLoading
            ? LoaderWidget()
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Form(
                  key: _formKey,
                  child: SafeArea(
                    child: ListView(
                      padding: EdgeInsets.all(30),
                      children: [
                        iconBackButton(context),
                        ShowAlert(
                          warning: _warning,
                          function: () {
                            setState(() {
                              _warning = null;
                            });
                          },
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text(
                          'Войти',
                          style: TextStyle(
                              fontSize: 70,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        TextFormEmailField(emailController: _emailController),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormPassField(passController: _passController),
                        SizedBox(
                          height: 30,
                        ),
                        enterButton(
                          _formKey,
                          _submitForm,
                          'Войти',
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        apple.AppleSignInButton(
                          style: apple.ButtonStyle.white,
                          type: apple.ButtonType.signIn,
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            BlocProvider.of<VpnAuthBloc>(context)
                                .add(VpnLoginWithAppleIdEvent());
                          },
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ForgetScreen()));
                            },
                            child: Container(
                              child: Text(
                                'Восстановить пароль',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _submitForm() async {
    setState(() => _isLoading = true);
    BlocProvider.of<VpnAuthBloc>(context).add(VpnLoginEvent(
        login: _emailController.text.trim(),
        password: _passController.text.trim()));
  }
}
