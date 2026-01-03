import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static DocumentReference get _ref =>
      _db.collection('users').doc(_auth.currentUser!.uid);

  /// Stream coin realtime
  static Stream<int> pointStream() {
    return _ref.snapshots().map((doc) => doc['wallet']['point'] as int);
  }

  /// Cộng coin (demo)
  static Future<void> addCoin(int amount) async {
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_ref);
      final current = snap['wallet']['point'];

      tx.update(_ref, {
        'wallet.point': current + amount,
        'wallet.updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Bet cho game
  static Future<void> bet(int amount, bool win) async {
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_ref);
      final current = snap['wallet']['point'];

      if (current < amount) {
        throw Exception("Không đủ coin");
      }

      tx.update(_ref, {
        'wallet.point': win ? current + amount : current - amount,
        'wallet.updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
  
}
