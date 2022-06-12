import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_form_flutter/models/all_categories_model.dart';
import 'package:login_form_flutter/models/all_products_model.dart';
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
      debugShowCheckedModeBanner: false,
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
  List<AllCategoriesData>? categories;
  List<AllProductsData>? products;

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
                  // this is 'Spread' operator it will combine it with above mentioned condition
                  TextField(controller: userNameCtrl),
                  TextField(controller: passwordCtrl),
                  ElevatedButton(onPressed: login, child: Text("Login"))
                ],
                if (userData != null) Text(userData?.accessToken ?? ""),
                if (products != null)
                  Expanded(
                      child: ListView.builder(
                    itemCount: products!.length,
                    itemBuilder: (_, index) => ListTile(
                      title: Text(products![index].title ?? ""),
                      leading: Image.network(products![index].image ?? ""),
                      subtitle: Text("Price: ${products![index].price}"),
                    ),
                  ))
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
      await getAllProducts(); // Categories method call
      // here await will stop this 'try' until categories not get
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getAllCategories() async {
    var url = Uri.parse('http://ishaqhassan.com:2000/category');
    setState(() {
      isLoading = true;
    });
    try {
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${userData?.accessToken}"});
      var responseJSON =
          AllCategoriesResponse.fromJson(jsonDecode(response.body));
      setState(() {
        categories = responseJSON.data;
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

  Future<void> getAllProducts() async {
    var url = Uri.parse('http://ishaqhassan.com:2000/product');
    setState(() {
      isLoading = true;
    });
    try {
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${userData?.accessToken}"});
      var responseJSON =
          AllProductsResponse.fromJson(jsonDecode(response.body));
      setState(() {
        products = responseJSON.data;
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
