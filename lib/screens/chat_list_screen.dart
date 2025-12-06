import 'package:flutter/material.dart';
import 'package:test_demo_firebase/models/chat_model.dart';
import 'package:test_demo_firebase/services/chat_service.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({Key? key}) : super(key: key);

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final String uid = 'currentUserId';

    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), elevation: 0),
      body: StreamBuilder<List<ChatModel>>(
        stream: _chatService.getUserChats(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!;
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No messages yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Contact sellers to start chatting',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text('${index + 1}'),
                ),
                title: Text(
                  chat.lastMessage.isNotEmpty
                      ? chat.lastMessage
                      : 'Conversation',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Listing: ${chat.listingId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(radius: 3, backgroundColor: Colors.blue),
                    const SizedBox(height: 4),
                    Text(
                      chat.updatedAt?.toString().split(' ')[0] ?? 'Today',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () =>
                    Navigator.of(context).pushNamed('/chat', arguments: chat),
              );
            },
          );
        },
      ),
    );
  }
}
