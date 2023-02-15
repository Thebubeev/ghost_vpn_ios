import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_bloc.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_event.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_state.dart';
import 'package:ghost_vpn_ios/services/firebase_api_services.dart';
import 'package:ghost_vpn_ios/widgets/loader_widget.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;
import 'package:ghost_vpn_ios/widgets/widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseApiServices auth = FirebaseApiServices();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  String? _warning;
  bool _isLoading = false;

  @override
  void dispose() {
    if (!mounted) return;
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _warning = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VpnAuthBloc, VpnAuthState>(
      listener: (context, state) async {
        if (state is VpnAuthRegisterToastState) {
          setState(() {
            _isLoading = false;
            _warning = 'Пожалуйста, подтвердите вашу почту.';
          });
          await auth.sendVerificationEmail();
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
            ? const LoaderWidget()
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Form(
                  key: _formKey,
                  child: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(30),
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
                        const SizedBox(
                          height: 25,
                        ),
                        const Text(
                          'Регистрация',
                          style: TextStyle(
                              fontSize: 45,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextFormEmailField(emailController: _emailController),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormPassField(passController: _passController),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormConfirmPassField(
                            passController: _passController,
                            confirmPassController: _confirmPassController),
                        const SizedBox(
                          height: 45,
                        ),
                        enterButton(
                          _formKey,
                          _submitForm,
                          'Зарегистрироваться',
                        ),
                        const SizedBox(
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
    BlocProvider.of<VpnAuthBloc>(context).add(VpnRegisterEvent(
        login: _emailController.text.trim(),
        password: _passController.text.trim()));
  }
}
