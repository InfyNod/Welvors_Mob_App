import 'dart:math';
import 'package:lottie/lottie.dart';
import '../../export.dart';

class VideoVerificationScreen extends StatefulWidget {
  const VideoVerificationScreen({super.key});

  @override
  State<VideoVerificationScreen> createState() =>
      _VideoVerificationScreenState();
}

class _VideoVerificationScreenState extends State<VideoVerificationScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  late AnimationController _rotationController;

  final List<Map<String, String>> steps = [
    {"emoji": "👁", "title": "Blink slowly twice"},
    {"emoji": "↔️", "title": "Turn your head left, then right"},
    {"emoji": "😀", "title": "Smile for the camera"},
  ];

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void nextGesture() {
    if (currentIndex < steps.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Verification Completed")));
      Navigator.of(
        context,
      ).popUntil((route) => route.settings.name == '/TrustVerificationScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentIndex];

    return Scaffold(
      backgroundColor: Mycolor.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Video Verification",
          style: TextStyle(
            color: Color(0xff25212F),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Mycolor.creamlight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "🎥 A 3-second live video. Follow the prompts — this proves you're real, not a photo or deepfake.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Mycolor.pink3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              hSized40,
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _rotationController,
                          builder: (_, _) {
                            return Transform.rotate(
                              angle: _rotationController.value * 2 * pi,
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 20),
                                tween: Tween<double>(
                                  begin: 0,
                                  end: (currentIndex + 1) / steps.length,
                                ),
                                builder: (_, value, _) {
                                  return CustomPaint(
                                    size: const Size(320, 320),
                                    painter: ArcPainter(value),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),

                        /// Replace with CameraPreview(controller)
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          height: MediaQuery.of(context).size.height - 200,
                          child: currentIndex == 2
                              ? Lottie.asset(
                                  Apiserver.lottie,
                                  repeat: true,
                                  fit: BoxFit.contain,
                                )
                              : Center(
                                  child: Text(
                                    step["emoji"]!,
                                    style: const TextStyle(fontSize: 60),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                step["title"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              hSized15,

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  steps.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index <= currentIndex
                          ? Mycolor.redlight
                          : Mycolor.grey2,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: nextGesture,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Mycolor.pink, Mycolor.pink1],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        currentIndex == steps.length - 1
                            ? "Finish & verify"
                            : "Next gesture →",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  final double progress;

  ArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Mycolor.redlight
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 120);

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress, // <-- fill according to progress
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
