import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:justsing/views/android/login.page.dart';

class RegistryPage extends StatefulWidget {
  const RegistryPage({super.key});

  @override
  State<RegistryPage> createState() => _RegistryPageState();
}

class _RegistryPageState extends State<RegistryPage> {
  final _usuarioController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _firebaseAuth = FirebaseAuth.instance;

  bool loading = false;

  Widget inputs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: TextFormField(
                  controller: _usuarioController,
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                    labelText: 'Usuário',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.orange,
                    suffixIcon: Icon(Icons.person_outline, color: Colors.white),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
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
                    suffixIcon: Icon(Icons.email_outlined, color: Colors.white),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.orange,
                    suffixIcon: Icon(Icons.lock_outline, color: Colors.white),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
          Container(
            child: inputs(),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 35),
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
                            cadastrar();
                          },
                          child: Text('Cadastrar-se'),
                          color: Colors.orange,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  cadastrar() async {
    setState(() {
      loading = true;
    });
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: _emailController.text, password: _senhaController.text);
      if (userCredential != null) {
        await userCredential.user!.updateDisplayName(_usuarioController.text);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
        if (e.code == 'weak-passoword') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Crie uma senha mais forte')));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email já está sendo usado')));
        }
      });
    }
  }
}
