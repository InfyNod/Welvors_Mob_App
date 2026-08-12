import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '../../../constant/Apiserver.dart';
import '../../../utils/mycolor.dart';

class AnimatedDottedCircle extends StatefulWidget {
  final double size;

  const AnimatedDottedCircle({super.key, this.size = 260});

  @override
  State<AnimatedDottedCircle> createState() => AnimatedDottedCircleState();
}

class AnimatedDottedCircleState extends State<AnimatedDottedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final ImagePicker _picker = ImagePicker();

  File? _image;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  Future<void> pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (file != null) {
      setState(() {
        _image = File(file.path);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size - 20,
      height: widget.size - 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// Rotating Border
          AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: child,
              );
            },
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: DottedCirclePainter(),
            ),
          ),

          /// Image (Not Rotating)
          ClipOval(
            child: Container(
              width: widget.size - 50,
              height: widget.size - 50,
              color: Colors.white,
              child: _image == null
                  ? Center(
                      child: Lottie.asset(
                        Apiserver.lottie,
                        width: widget.size - 100,
                        height: widget.size - 100,
                      ),
                    )
                  : Image.file(_image!, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Mycolor.pinklight
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashWidth = 5.0;
    const dashSpace = 10.0;

    final radius = size.width / 2;

    final circumference = 2 * pi * radius;

    double distance = 0;

    while (distance < circumference) {
      final startAngle = distance / radius;

      final sweepAngle = dashWidth / radius;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius - 4),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
