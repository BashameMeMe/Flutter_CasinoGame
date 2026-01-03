import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class WalletService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static DocumentReference<Map<String, dynamic>> get _ref {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User chưa đăng nhập");
    }
    return _db.collection('users').doc(user.uid);
  }

  /// 💰 Coin realtime
  static Stream<int> pointStream() {
    return _ref.snapshots().map((doc) {
      if (!doc.exists) return 0;
      return doc.data()?['point'] ?? 0;
    });
  }

  /// ➕ Cộng coin
  //   static Future<bool> addPoint(int amount) async {
  //   try {
  //     await _db.runTransaction((tx) async {
  //       final snap = await tx.get(_ref);

  //       final current = snap.data()?['point'] ?? 0;

  //       tx.set(
  //         _ref,
  //         {
  //           'point': current + amount,
  //         },
  //         SetOptions(merge: true),
  //       );
  //     });
  //     return true;
  //   } catch (e, s) {
  //     debugPrint("❌ addPoint error: $e");
  //     debugPrintStack(stackTrace: s);
  //     return false;
  //   }
  // }
  static Future<void> addPoint(int value) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    await ref.update({'point': FieldValue.increment(value)});
  }

  static Future<bool> deductPoint(int value) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final snap = await ref.get();

    final current = snap['point'] ?? 0;
    if (current < value) return false;

    await ref.update({'point': current - value});
    return true;
  }

  /// 🎮 Bet game
  static Future<bool> bet(int amount, bool win) async {
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(_ref);
        final current = snap.data()?['point'] ?? 0;

        if (current < amount) {
          throw Exception("Không đủ coin");
        }

        tx.update(_ref, {'point': win ? current + amount : current - amount});
      });
      return true;
    } catch (e, s) {
      debugPrint("❌ bet error: $e");
      debugPrintStack(stackTrace: s);
      return false;
    }
  }
}
