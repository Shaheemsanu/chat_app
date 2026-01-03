import 'package:flutter/material.dart';

import 'chat_bubble_clipper.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String senderId;
  final String timestamp;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.senderId,
    required this.timestamp,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: isMe
                ? const Radius.circular(16.0)
                : const Radius.circular(0.0),
            bottomRight: isMe
                ? const Radius.circular(0.0)
                : const Radius.circular(16.0),
          ),
        ),
        child: ClipPath(
          clipper: ChatBubbleClipper(isSender: isMe),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: 12,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 8.0,
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
