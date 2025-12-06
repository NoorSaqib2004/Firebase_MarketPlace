import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String text;
  final Timestamp? timestamp;
  final bool seen;
  final String? imageUrl;

  MessageModel({
    required this.senderId,
    required this.text,
    this.timestamp,
    required this.seen,
    this.imageUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] as Timestamp?,
      seen: map['seen'] ?? false,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'seen': seen,
      'imageUrl': imageUrl,
    };
  }

  MessageModel copyWith({
    String? senderId,
    String? text,
    Timestamp? timestamp,
    bool? seen,
    String? imageUrl,
  }) {
    return MessageModel(
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      seen: seen ?? this.seen,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'MessageModel(senderId: $senderId, text: $text, timestamp: $timestamp, seen: $seen, imageUrl: $imageUrl)';
  }
}
