// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:justsing/views/android/search.page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _firebaseAuth = FirebaseAuth.instance;

  bool loading = false;

  bool showPassword = false;

  Widget inputs() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Colors.orange,
            decoration: InputDecoration(
              labelText: 'E-mail',
              labelStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.orange,
              prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(25)),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: TextFormField(
            controller: _senhaController,
            obscureText: showPassword == false ? true : false,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Colors.orange,
            decoration: InputDecoration(
              labelText: 'Senha',
              labelStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.orange,
              suffixIcon: GestureDetector(
                child: Icon(
                  showPassword == false
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white,
                ),
                onTap: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
              ),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(25)),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/registry'),
              child: Text(
                'Cadastrar-se',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void saveDisplayName(String name) async {
    var sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setString("displayName", name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[850],
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Text(
                'justSing!',
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 50,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(child: inputs()),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: (loading)
                      ? [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white)),
                          )
                        ]
                      : [
                          MaterialButton(
                            onPressed: () {
                              login();
                            },
                            child: Text('Login'),
                            color: Colors.orange,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          )
                        ],
                ),
              ),
            ),
          ]),
    );
  }

  login() async {
    setState(() {
      loading = true;
    });
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
              email: _emailController.text, password: _senhaController.text);

      if (userCredential != null) {
        saveDisplayName(userCredential.user!.displayName.toString());

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(),
            ),
            (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      print("fail oi ");
      setState(() {
        loading = false;
      });
      if (e.code == 'user-not=found') {
        print("oi2");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario não encontrado')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Senha está incorreta')));
      }
    }
  }
}
