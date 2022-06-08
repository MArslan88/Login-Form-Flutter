import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_form_flutter/models/login_response.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  UserData? userData;

  //for loading animation
  bool isLoading = false;

  String? error;

  TextEditingController userNameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HTTP Demo"),
      ),
      body: !isLoading
          ? Column(
              children: [
                if (error != null) Text("There is an error : $error"),
                if (userData == null) ...[
                  TextField(controller: userNameCtrl),
                  TextField(controller: passwordCtrl),
                  ElevatedButton(onPressed: login, child: Text("Login"))
                ],
                if (userData != null) Text(userData?.accessToken ?? "")
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  void login() async {
    var url = Uri.parse('http://ishaqhassan.com:2000/user/signin');
    setState(() {
      isLoading = true;
    });
    try {
      var response = await http.post(url,
          body: {'email': userNameCtrl.text, 'password': passwordCtrl.text});
      var responseJSON = LoginResponse.fromJson(jsonDecode(response.body));
      setState(() {
        userData = responseJSON.data;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
