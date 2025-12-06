import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_demo_firebase/models/listing_model.dart';

class ListingService {
  final CollectionReference _listings = FirebaseFirestore.instance.collection(
    'listings',
  );

  Future<void> createListing(ListingModel listing) async {
    try {
      final doc = _listings.doc(listing.listingId);
      await doc.set(listing.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<ListingModel>> fetchListings() {
    return _listings.orderBy('createdAt', descending: true).snapshots().map((
      snap,
    ) {
      return snap.docs
          .map((d) => ListingModel.fromMap(d.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<ListingModel>> searchListingsByTitle(String query) async {
    try {
      final end = query + '\uf8ff';
      final snap = await _listings
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: end)
          .get();
      return snap.docs
          .map((d) => ListingModel.fromMap(d.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ListingModel>> filterListingsByPrice(
    double min,
    double max,
  ) async {
    try {
      final snap = await _listings
          .where('price', isGreaterThanOrEqualTo: min)
          .where('price', isLessThanOrEqualTo: max)
          .get();
      return snap.docs
          .map((d) => ListingModel.fromMap(d.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<ListingModel>> fetchListingsByUser(String userId) {
    return _listings.where('ownerId', isEqualTo: userId).snapshots().map((
      snap,
    ) {
      return snap.docs
          .map((d) => ListingModel.fromMap(d.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> updateListingStatus(String listingId, String status) async {
    try {
      await _listings.doc(listingId).update({'status': status});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateListing(ListingModel listing) async {
    try {
      await _listings.doc(listing.listingId).update(listing.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteListing(String listingId) async {
    try {
      await _listings.doc(listingId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
