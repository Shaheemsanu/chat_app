
import 'package:flutter/material.dart';

class ChatBubbleClipper extends CustomClipper<Path> {
  final bool isSender;

  ChatBubbleClipper({required this.isSender});

  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 16.0;

    if (isSender) {
      path.moveTo(0, size.height - radius);
      path.arcToPoint(
        Offset(radius, size.height),
        radius: const Radius.circular(radius),
      );
      path.lineTo(size.width - radius, size.height);
      path.arcToPoint(
        Offset(size.width, size.height - radius),
        radius: const Radius.circular(radius),
      );
      path.lineTo(size.width, radius);
      path.arcToPoint(
        Offset(size.width - radius, 0),
        radius: const Radius.circular(radius),
      );
      path.lineTo(radius, 0);
      path.arcToPoint(
        const Offset(0, radius),
        radius: const Radius.circular(radius),
      );
    } else {
      path.moveTo(radius, size.height);
      path.lineTo(radius, radius);
      path.arcToPoint(
        const Offset(0, 0),
        radius: const Radius.circular(radius),
      );
      path.lineTo(size.width - radius, 0);
      path.arcToPoint(
        Offset(size.width, radius),
        radius: const Radius.circular(radius),
      );
      path.lineTo(size.width, size.height - radius);
      path.arcToPoint(
        Offset(size.width - radius, size.height),
        radius: const Radius.circular(radius),
      );
      path.lineTo(radius, size.height);
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
