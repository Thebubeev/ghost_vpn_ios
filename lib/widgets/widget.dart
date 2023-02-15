import 'package:flutter/material.dart';

void _fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

bool _isPasswordVisible = false;

class TextFormEmailField extends StatefulWidget {
  final TextEditingController emailController;
  const TextFormEmailField({Key? key, required this.emailController})
      : super(key: key);

  @override
  State<TextFormEmailField> createState() => _TextFormEmailFieldState();
}

class _TextFormEmailFieldState extends State<TextFormEmailField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Gilroy'),
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
      ),
      controller: widget.emailController,
      validator: (val) {
        if (val!.isEmpty || val == '') {
          return 'Введите почту';
        } else if (val.contains('@') == false || (val.contains('.') == false)) {
          return 'Введите настоящую почту!';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        setState(() {
          widget.emailController.text = val as String;
        });
      },
    );
  }
}

class TextFormPassField extends StatefulWidget {
  final TextEditingController passController;
  const TextFormPassField({Key? key, required this.passController})
      : super(key: key);

  @override
  State<TextFormPassField> createState() => _TextFormPassFieldState();
}

class _TextFormPassFieldState extends State<TextFormPassField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          labelText: 'Пароль',
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Gilroy'),
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10)),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            icon: Icon(
              _isPasswordVisible == true
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white,
            ),
          )),
      controller: widget.passController,
      validator: (val) {
        if (val!.isEmpty || val == '') {
          return 'Введите пароль';
        } else if (val.length < 6) {
          return 'Пароль должен быть больше 6 символов';
        } else {
          return null;
        }
      },
      obscureText: _isPasswordVisible ? false : true,
      onSaved: (val) {
        setState(() {
          widget.passController.text = val as String;
        });
      },
    );
  }
}

class TextFormConfirmPassField extends StatefulWidget {
  final TextEditingController passController, confirmPassController;
  const TextFormConfirmPassField(
      {Key? key,
      required this.passController,
      required this.confirmPassController})
      : super(key: key);

  @override
  State<TextFormConfirmPassField> createState() =>
      _TextFormConfirmPassFieldState();
}

class _TextFormConfirmPassFieldState extends State<TextFormConfirmPassField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          labelText: 'Подтвердите пароль',
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Gilroy'),
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10)),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            icon: Icon(
              _isPasswordVisible == true
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white,
            ),
          )),
      controller: widget.confirmPassController,
      validator: (val) {
        if (val!.isEmpty || val == '') {
          return 'Введите пароль';
        } else if (val.length < 6) {
          return 'Пароль должен быть больше 6 символов';
        } else if (val.trim() != widget.passController.text.trim()) {
          return "Пароли должны быть одинаковыми";
        } else {
          return null;
        }
      },
      obscureText: _isPasswordVisible ? false : true,
      onSaved: (val) {
        setState(() {
          widget.passController.text = val as String;
        });
      },
    );
  }
}

class ShowAlert extends StatefulWidget {
  String? warning;
  Function? function;
  ShowAlert({Key? key, this.warning, this.function}) : super(key: key);

  @override
  State<ShowAlert> createState() => _ShowAlertState();
}

class _ShowAlertState extends State<ShowAlert> {
  @override
  Widget build(BuildContext context) {
    if (widget.warning != null) {
      return Container(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            const Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Icon(Icons.error_outline, color: Colors.black)),
            Expanded(
              child: Text(
                widget.warning!,
                style: const TextStyle(
                    fontSize: 18, fontFamily: 'Gilroy', color: Colors.black),
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
                onPressed: () {
                  widget.function!();
                },
              ),
            )
          ],
        ),
      );
    }
    return const SizedBox(height: 0);
  }
}

Widget iconBackButton(BuildContext context) => IconButton(
    padding: const EdgeInsets.only(top: 15, bottom: 15),
    alignment: Alignment.topLeft,
    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
    iconSize: 35,
    onPressed: () {
      Navigator.pop(context);
    });

Widget enterButton(
  GlobalKey<FormState> _formKey,
  Function _submitForm,
  String text,
) =>
    GestureDetector(
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            _submitForm();
          }
        },
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              color: Colors.white),
          height: 70,
          width: 300,
          child: Center(
              child: Text(
            text,
            style: const TextStyle(
                color: Colors.black, fontFamily: 'Gilroy', fontSize: 17),
          )),
        ));
