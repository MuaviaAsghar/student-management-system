import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class Student {
  String id;
  final String name;
  final String email;
  final String password;
  String profilePictureUrl;

  Student({
    this.id = '',
    required this.name,
    required this.email,
    required this.password,
    this.profilePictureUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': 'student',
      'profilePictureUrl': profilePictureUrl,
    };
  }

  Future<String> createUser(String email, String password) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user!.uid; // Return the newly created user's ID
  }

  Future<void> registerUser(String email, String password) async {
    // final AuthResponse response = await Supabase.instance.client.auth.signUp(
    //   email: email,
    //   password: password,
    // );

    //   // Check if there is an error in the response
    //   if (response.user == null) {
    //     // If the user is null, it means there was an issue (like needing to confirm the email)
    //     if (response.session == null) {
    //       print(
    //           'Registration error: User already registered or confirmation needed.');
    //     }
    //   } else {
    //     print('User registered: ${response.user!.email}');
    //   }
  }

  Future<void> saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc('students_index')
        .update({
      'studentEmails': FieldValue.arrayUnion([email]),
    });
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc('students')
        .collection(email.trim())
        .doc(user.uid);
    await docRef.set(toMap());
    id = docRef.id;
  }
}
