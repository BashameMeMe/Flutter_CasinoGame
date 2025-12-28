import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= AUTH =================

  Future<String?> registerUser(
      String email, String password, String username) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'username': username,
        'balance': 10000,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ================= USER DATA =================

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    final uid = _auth.currentUser!.uid;
    return _db.collection('users').doc(uid).snapshots();
  }

  // ================= BALANCE =================

  /// Kiểm tra đủ tiền cược
  Future<bool> canBet(int bet) async {
    final uid = _auth.currentUser!.uid;
    final snap = await _db.collection('users').doc(uid).get();
    final balance = snap.data()?['balance'] ?? 0;
    return bet > 0 && balance >= bet;
  }

  /// Thay đổi tiền (+ thắng / - thua)
  Future<void> changeBalance(int delta) async {
    final uid = _auth.currentUser!.uid;
    final ref = _db.collection('users').doc(uid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = snap.data()?['balance'] ?? 0;
      tx.update(ref, {'balance': current + delta});
    });
  }
}
