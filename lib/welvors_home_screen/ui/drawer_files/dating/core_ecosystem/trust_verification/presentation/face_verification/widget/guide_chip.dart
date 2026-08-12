import '../../../export.dart';

class GuideChip extends StatelessWidget {
  final String title;

  const GuideChip({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Mycolor.greenlight1,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        "✓ $title",
        style: const TextStyle(
          color: Mycolor.green1,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
