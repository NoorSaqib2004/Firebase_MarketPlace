import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_demo_firebase/models/favorite_model.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToFavorites(String uid, String listingId) async {
    try {
      final doc = _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(listingId);
      await doc.set({'listingId': listingId});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromFavorites(String uid, String listingId) async {
    try {
      final doc = _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(listingId);
      await doc.delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<FavoriteModel>> getUserFavorites(String uid) {
    final coll = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites');
    return coll.snapshots().map(
      (snap) => snap.docs.map((d) => FavoriteModel.fromMap(d.data())).toList(),
    );
  }
}
