import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_demo_firebase/models/chat_model.dart';
import 'package:test_demo_firebase/models/message_model.dart';

class ChatService {
  final CollectionReference _chats = FirebaseFirestore.instance.collection(
    'chats',
  );

  Future<String> createChat(
    String buyerId,
    String sellerId,
    String listingId,
  ) async {
    try {
      final chatRef = _chats.doc();
      final chat = ChatModel(
        chatId: chatRef.id,
        users: [buyerId, sellerId],
        listingId: listingId,
        lastMessage: '',
        updatedAt: Timestamp.now(),
      );
      await chatRef.set(chat.toMap());
      return chatRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      final messagesRef = _chats.doc(chatId).collection('messages');
      await messagesRef.add(message.toMap());
      await _chats.doc(chatId).update({
        'lastMessage': message.text,
        'updatedAt': message.timestamp ?? Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    final messagesRef = _chats.doc(chatId).collection('messages');
    return messagesRef.orderBy('timestamp', descending: false).snapshots().map((
      snap,
    ) {
      return snap.docs.map((d) => MessageModel.fromMap(d.data())).toList();
    });
  }

  Stream<List<ChatModel>> getUserChats(String uid) {
    return _chats
        .where('users', arrayContains: uid)
        .snapshots()
        .map((snap) {
          final chats = snap.docs
              .map((d) => ChatModel.fromMap(d.data() as Map<String, dynamic>))
              .toList();
          // Sort in memory instead of in Firestore to avoid composite index requirement
          chats.sort((a, b) {
            final aTime = a.updatedAt?.millisecondsSinceEpoch ?? 0;
            final bTime = b.updatedAt?.millisecondsSinceEpoch ?? 0;
            return bTime.compareTo(aTime); // Descending order
          });
          return chats;
        });
  }

  Future<ChatModel?> getChatBetweenUsers(
    String userId1,
    String userId2,
    String listingId,
  ) async {
    try {
      final query = await _chats
          .where('users', arrayContains: userId1)
          .where('listingId', isEqualTo: listingId)
          .get();

      for (var doc in query.docs) {
        final chat = ChatModel.fromMap(doc.data() as Map<String, dynamic>);
        if (chat.users.contains(userId2)) {
          return chat;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
