import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserDataProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? name;
  String? email;
  String? profilePictureUrl;

  bool isEditing = false;

  UserDataProvider() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        name = data['name'];
        email = data['email'];
        profilePictureUrl = data['profilePictureUrl'];
        notifyListeners();
      }
    }
  }

  Future<void> saveUpdates(String newName, String newEmail) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).update({
        'name': newName,
        'email': newEmail,
        'profilePictureUrl': profilePictureUrl,
      });
      name = newName;
      email = newEmail;
      isEditing = false;
      notifyListeners();
    }
  }

  void toggleEditing() {
    isEditing = !isEditing;
    notifyListeners();
  }
}
