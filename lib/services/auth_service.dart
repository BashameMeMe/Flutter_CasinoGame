import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register(String email, String password) async {
    if (email.isEmpty || password.length < 6) {
      throw Exception("Email hoặc mật khẩu không hợp lệ");
    }

    final res = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(res.user!.uid).set({
      'uid': res.user!.uid,
      'email': email,
      'wallet': {'point': 0, 'updatedAt': FieldValue.serverTimestamp()},
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('users').doc(res.user!.uid).set({
      'uid': res.user!.uid,
      'email': email,
      'point': 0,
    });
  }

  void logout() {
    _auth.signOut();
  }
}
