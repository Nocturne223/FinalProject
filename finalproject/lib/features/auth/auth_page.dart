import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLogin = true;

  void toggleView() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return LoginPage(onCreateAccountTap: toggleView);
    } else {
      return RegisterPage(onLoginTap: toggleView);
    }
  }
}
