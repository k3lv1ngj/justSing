import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:justsing/firebase_options.dart';
import 'package:justsing/views/android/android.app.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(AndroidApp());
}

class JustSing extends StatelessWidget {
  const JustSing({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'justSing!',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
    );
  }
}
