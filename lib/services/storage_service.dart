import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String uid, File file) async {
    try {
      final ref = _storage.ref().child(
        'profiles/$uid/${DateTime.now().millisecondsSinceEpoch}',
      );
      final task = await ref.putFile(file);
      final url = await task.ref.getDownloadURL();
      return url;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> uploadListingImages(
    String listingId,
    List<File> files,
  ) async {
    try {
      final urls = <String>[];
      for (var file in files) {
        final ref = _storage.ref().child(
          'listings/$listingId/${DateTime.now().millisecondsSinceEpoch}',
        );
        final task = await ref.putFile(file);
        final url = await task.ref.getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadChatImage(String chatId, File file) async {
    try {
      final ref = _storage.ref().child(
        'chats/$chatId/${DateTime.now().millisecondsSinceEpoch}',
      );
      final task = await ref.putFile(file);
      final url = await task.ref.getDownloadURL();
      return url;
    } catch (e) {
      rethrow;
    }
  }
}
