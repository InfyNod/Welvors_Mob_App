import 'package:flutter/material.dart';

class MessageBubblePainter extends CustomPainter {
  final bool isMine;
  final Color color;

  MessageBubblePainter({required this.isMine, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double radius = 18;
    const double tailWidth = 13;
    const double tailHeight = 13;

    final path = Path();

    if (isMine) {
      // ==========================================
      // RIGHT SIDE MESSAGE
      // TOP RIGHT WHATSAPP STYLE TAIL
      // ==========================================

      path.moveTo(radius, 0);

      // Top
      path.lineTo(size.width - radius - tailWidth, 0);

      // Top-right curve + tail
      path.quadraticBezierTo(
        size.width - tailWidth,
        0,
        size.width - tailWidth + 2,
        7,
      );

      path.quadraticBezierTo(size.width - tailWidth + 5, 12, size.width, 12);

      // Right side
      path.lineTo(size.width, size.height - radius);

      // Bottom-right
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      );

      // Bottom
      path.lineTo(radius, size.height);

      // Bottom-left
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);

      // Left
      path.lineTo(0, radius);

      // Top-left
      path.quadraticBezierTo(0, 0, radius, 0);
    } else {
      // ==========================================
      // LEFT SIDE MESSAGE
      // TOP LEFT WHATSAPP STYLE TAIL
      // ==========================================

      path.moveTo(radius + tailWidth, 0);

      // Top-left tail
      path.lineTo(size.width - radius, 0);

      // Top-right
      path.quadraticBezierTo(size.width, 0, size.width, radius);

      // Right
      path.lineTo(size.width, size.height - radius);

      // Bottom-right
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      );

      // Bottom
      path.lineTo(radius, size.height);

      // Bottom-left
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);

      // Left
      path.lineTo(0, radius + tailHeight);

      // LEFT TOP TAIL
      path.quadraticBezierTo(0, radius, 7, radius - 2);

      path.quadraticBezierTo(12, radius - 2, 12, 0);

      // Top-left
      path.lineTo(radius + tailWidth, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MessageBubblePainter oldDelegate) {
    return oldDelegate.isMine != isMine || oldDelegate.color != color;
  }
}

class MessageBubbleClipper extends CustomClipper<Path> {
  final bool isMine;

  MessageBubbleClipper({required this.isMine});

  @override
  Path getClip(Size size) {
    const double radius = 18;
    const double tail = 13;

    final path = Path();

    if (isMine) {
      // RIGHT MESSAGE

      path.moveTo(radius, 0);

      path.lineTo(size.width - radius - tail, 0);

      // Top-right tail
      path.quadraticBezierTo(size.width - tail, 0, size.width - tail + 2, 7);

      path.quadraticBezierTo(size.width - tail + 5, 12, size.width, 12);

      path.lineTo(size.width, size.height - radius);

      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      );

      path.lineTo(radius, size.height);

      path.quadraticBezierTo(0, size.height, 0, size.height - radius);

      path.lineTo(0, radius);

      path.quadraticBezierTo(0, 0, radius, 0);
    } else {
      // LEFT MESSAGE

      path.moveTo(radius + tail, 0);

      path.lineTo(size.width - radius, 0);

      path.quadraticBezierTo(size.width, 0, size.width, radius);

      path.lineTo(size.width, size.height - radius);

      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      );

      path.lineTo(radius, size.height);

      path.quadraticBezierTo(0, size.height, 0, size.height - radius);

      path.lineTo(0, radius + 13);

      // Top-left tail
      path.quadraticBezierTo(0, radius, 7, radius - 2);

      path.quadraticBezierTo(12, radius - 2, 12, 0);

      path.lineTo(radius + tail, 0);
    }

    return path;
  }

  @override
  bool shouldReclip(covariant MessageBubbleClipper oldClipper) {
    return oldClipper.isMine != isMine;
  }
}

class WhatsAppTailPainter extends CustomPainter {
  final bool isMine;
  final Color color;

  WhatsAppTailPainter({required this.isMine, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isMine == false) {
      // RIGHT SIDE TAIL
      path.moveTo(size.width, 0);
      path.cubicTo(size.width - -20, -6, size.width - 2, 22, 0, 20);
      path.cubicTo(12, 10, 10, 5, 10, 0);
    } else {
      // LEFT SIDE TAIL
      // Main rounded box se start
      path.moveTo(size.width - 10, 0);

      // Niche aur bahar ki taraf tail banana
      path.quadraticBezierTo(size.width, 0, size.width, 10);

      // Tail ko wapas bubble ki taraf curved connect karna
      path.quadraticBezierTo(size.width - 2, 18, size.width - 12, 15);

      // Baaki bubble box ko close karna
      path.lineTo(10, 15);
      path.quadraticBezierTo(0, 15, 0, 0);
      path.close();
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WhatsAppTailPainter oldDelegate) {
    return oldDelegate.isMine != isMine || oldDelegate.color != color;
  }
}
