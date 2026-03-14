
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();

  login() async {

    var res = await AuthService.login(
      email.text,
      password.text
    );

    print(res);

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(title: Text("RunBhoomi Login")),
      body: Column(
        children: [

          TextField(controller: email),
          TextField(controller: password),

          ElevatedButton(
            onPressed: login,
            child: Text("Login"),
          )

        ],
      ),
    );

  }

}
