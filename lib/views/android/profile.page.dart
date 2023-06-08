// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:justsing/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:justsing/resources/add.data.dart';

import 'display.page.dart';

String emptyPicture = "emptyProfilePicture.png";

class ProfilePage extends StatefulWidget {
  String? lastWords;

  ProfilePage({this.lastWords});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? name;
  Uint8List? _image;

  void setDisplayName() async {
    var sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      name = sharedPreferences.getString("displayName") ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    setDisplayName();
  }

  Future selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  Future selectImageCamera() async {
    Uint8List img = await pickImage(ImageSource.camera);
    setState(() {
      _image = img;
    });
  }

  Future saveProfile() async {
    String resp = await StoreData().saveData(file: _image!);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.grey[850]),
      home: Scaffold(
        appBar: AppBar(
            title: Text('justSing!'),
            elevation: 0,
            leading: GestureDetector(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop('/search'),
                child: Icon(Icons.home),
              ),
            ),
            actions: [
              GestureDetector(
                child: ElevatedButton(
                  onPressed: () async {
                    await _firebaseAuth.signOut();
                    Navigator.of(context).pop('/search');
                  },
                  child: Text("Logout"),
                ),
              )
            ]),
        body: Padding(
          padding: const EdgeInsets.all(1),
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                      color: Colors.transparent,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: Container(
                                      child: Wrap(
                                        children: <Widget>[
                                          ListTile(
                                            leading: Icon(Icons.photo_library),
                                            title: Text('Galeria'),
                                            onTap: () async {
                                              await selectImage();
                                              await saveProfile();
                                              Navigator.of(context).pop();
                                              setState(() {});
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.camera_alt),
                                            title: Text('Câmera'),
                                            onTap: () async {
                                              await selectImageCamera();
                                              await saveProfile();
                                              Navigator.of(context).pop();
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: _firebaseAuth.currentUser!.photoURL != null
                              ? CircleAvatar(
                                  radius: 64,
                                  backgroundImage: NetworkImage(
                                      _firebaseAuth.currentUser!.photoURL!),
                                )
                              : CircleAvatar(
                                  radius: 64,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: AssetImage(
                                      'assets/emptyProfilePicture.png'),
                                ))),
                  //backgroundImage: NetworkImage(
                  //'https://www.promoview.com.br/uploads/images/unnamed%2819%29.png')))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                '${name}',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
            ),
            // ignore: prefer_const_constructors
            Container(
              width: double.infinity,
              child: Text(
                'Histórico',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('historico')
                        .where('uId', isEqualTo: _firebaseAuth.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      if (snapshot.hasError)
                        return Text(snapshot.error.toString());
                      var documents = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (_, index) {
                          final DocumentSnapshot doc =
                              snapshot.data!.docs[index];

                          return Card(
                            child: ListTile(
                              onTap: () async {
                                String _link = doc['link'];
                                print(_link);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PlayerPage(
                                              link: _link,
                                            )));
                              },
                              leading: Image.network(doc['thumb']),
                              title: Text(doc['title']),
                            ),
                          );
                        },
                      );
                    },
                  )),
            ),
          ]),
        ),
      ),
    );
  }
}
