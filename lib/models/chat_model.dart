import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> users;
  final String listingId;
  final String lastMessage;
  final Timestamp? updatedAt;

  ChatModel({
    required this.chatId,
    required this.users,
    required this.listingId,
    required this.lastMessage,
    this.updatedAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      users: List<String>.from(map['users'] ?? []),
      listingId: map['listingId'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'users': users,
      'listingId': listingId,
      'lastMessage': lastMessage,
      'updatedAt': updatedAt,
    };
  }

  ChatModel copyWith({
    String? chatId,
    List<String>? users,
    String? listingId,
    String? lastMessage,
    Timestamp? updatedAt,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      users: users ?? this.users,
      listingId: listingId ?? this.listingId,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ChatModel(chatId: $chatId, users: $users, listingId: $listingId, lastMessage: $lastMessage, updatedAt: $updatedAt)';
  }
}
