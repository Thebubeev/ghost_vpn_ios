import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_bloc.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_event.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_state.dart';
import 'package:ghost_vpn_ios/services/firebase_api_services.dart';
import 'package:ghost_vpn_ios/widgets/loader_widget.dart';
import 'package:ghost_vpn_ios/widgets/widget.dart';

class ForgetScreen extends StatefulWidget {
  @override
  _ForgetScreenState createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  final FirebaseApiServices auth = FirebaseApiServices();
  TextEditingController _emailController = TextEditingController();

  String? _warning;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    if (!mounted) return;
    _emailController.dispose();
    _warning = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VpnAuthBloc, VpnAuthState>(
      listener: (context, state) async {
        if (state is VpnAuthRecoveryPasswordState) {
          setState(() {
            _isLoading = false;
            _warning = 'Отправили ссылку на вашу почту';
          });
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
        resizeToAvoidBottomInset: false,
        body: _isLoading
            ? const LoaderWidget()
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Form(
                  key: _formKey,
                  child: SafeArea(
                    child:
                        ListView(padding: const EdgeInsets.all(30), children: [
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
                        'Восстановить пароль',
                        style: TextStyle(fontSize: 39, color: Colors.white),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(
                              height: 20.0,
                            ),
                            TextFormEmailField(
                              emailController: _emailController,
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            enterButton(
                              _formKey,
                              _submitForm,
                              'Восстановить пароль',
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                ),
              ),
      ),
    );
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    BlocProvider.of<VpnAuthBloc>(context).add(VpnForgotPasswordEvent(
      login: _emailController.text.trim(),
    ));
  }
}
