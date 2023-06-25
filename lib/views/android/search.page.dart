// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:justsing/views/android/result.page.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:justsing/views/android/profile.page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late StreamSubscription<ConnectivityResult> subscription;

  var isDeviceConnected = false;
  bool isAlertSet = false;

  final _firebaseAuth = FirebaseAuth.instance;

  bool _isListening = false;
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  Timer? _speechTimeoutTimer;

  @override
  void initState() {
    super.initState();
    getConnectivity();
    _initSpeech();
  }

  Future<void> getConnectivity() async {
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if (!isDeviceConnected && !isAlertSet) {
          showDialogBox();
          setState(() {
            isAlertSet = true;
          });
        } else if (isDeviceConnected && isAlertSet) {
          setState(() {
            Navigator.pop(context);
            isAlertSet = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    _speechTimeoutTimer?.cancel();
    super.dispose();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        setState(() {
          _lastWords = result.recognizedWords;
        });

        if (result.finalResult) {
          _stopListening();
          setState(() {
            _isListening = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewApp(lastWords: _lastWords),
            ),
          );
        }
      },
    );

    _speechTimeoutTimer = Timer(Duration(seconds: 10), () {
      _stopListening();
      setState(() {
        _isListening = false;
      });
    });
  }

  void changeListeningState() {
    setState(() {
      _isListening = !_isListening;

      if (!_speechEnabled) _initSpeech();

      _isListening ? _startListening() : _stopListening();
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    _speechTimeoutTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[850],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('justSing!'),
          actions: [
            _firebaseAuth.currentUser == null
                ? GestureDetector(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/login'),
                      child: Text("Login"),
                    ),
                  )
                : GestureDetector(
                    child: ElevatedButton(
                      onPressed: () async {
                        var result =
                            await Navigator.of(context).pushNamed('/profile');
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            lastWords: _lastWords,
                          ),
                        );
                        setState(() {});
                      },
                      child: Icon(Icons.person),
                    ),
                  )
          ],
        ),
        body: Column(
          children: [
            Text(
              "$_lastWords",
              style: TextStyle(color: Colors.amber, fontSize: 30),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Center(
          child: AvatarGlow(
            animate: _isListening,
            showTwoGlows: true,
            glowColor: Colors.amber,
            endRadius: 100,
            duration: const Duration(milliseconds: 2000),
            repeatPauseDuration: const Duration(milliseconds: 100),
            repeat: true,
            child: GestureDetector(
              onTap: () {
                _lastWords = '';
                changeListeningState();
              },
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.all(Radius.circular(360)),
                ),
                child: Icon(
                  _isListening ? Icons.mic_none_sharp : Icons.mic_sharp,
                  size: 100,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showDialogBox() {
    showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Sem conexão'),
        content: const Text('Verifique a conexão'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.pop(context, 'Cancel');
              setState(() => isAlertSet = false);
              isDeviceConnected =
                  await InternetConnectionChecker().hasConnection;
              if (!isDeviceConnected) {
                showDialogBox();
                setState(() => isAlertSet = true);
              }
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}
