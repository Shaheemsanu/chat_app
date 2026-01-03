
import 'package:chat_app_flutter/screens/chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final User userModel;
  final String chatId;
  const ChatScreen({
    super.key,
    required this.userModel,
    required this.chatId,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
      ),
      body: Column(
        children: [
          messagesStreamBuilder(),
          const SizedBox(
            height: 5,
          ),
          chatInput(context),
          const SizedBox(
            height: 14,
          ),
        ],
      ),
    );
  }

  Container chatInput(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          height: 56.0,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(32.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  sendingMsg();
                },
              ),
            ],
          ),
        );
  }

  Expanded messagesStreamBuilder() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final messages = snapshot.data!.docs;
          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ChatBubble(
                  message: message['message'],
                  senderId: message['senderId'],
                  timestamp: displayMessage(message['timestamp']),
                  isMe: message['senderId'] == widget.userModel.uid);
            },
          );
        },
      ),
    );
  }

  void sendingMsg() {
    if (_textEditingController.text.trim() != '') {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'senderEmail': widget.userModel.email,
        'senderId': widget.userModel.uid,
        'message': _textEditingController.text,
        'timestamp': Timestamp.now(),
      });
    }

    _textEditingController.clear();
  }

  String displayMessage(Timestamp? timestamp) {
    DateTime dateTime = DateTime.now();
    if (timestamp != null) {
      dateTime = timestamp.toDate();
    }

    String formattedDateTime = DateFormat('HH:mm a').format(dateTime);
    return formattedDateTime;
  }
}
