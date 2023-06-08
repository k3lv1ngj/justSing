import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:justsing/views/android/profile.page.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class StoreData {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref =
        _storage.ref().child(childName).child(_firebaseAuth.currentUser!.uid);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    await _firebaseAuth.currentUser!.updatePhotoURL(downloadUrl);
    return downloadUrl;
  }

  Future<String> saveData({required Uint8List file}) async {
    String resp = 'Algum erro aconteceu';

    try {
      await uploadImageToStorage('ProfileImage', file);

      resp = 'Sucesso';
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}
