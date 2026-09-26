import '../../../export.dart';

class PinkInfoBox extends StatelessWidget {
  final String text;

  const PinkInfoBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Mycolor.pinklight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Mycolor.pink1,
          height: 1.5,
        ),
      ),
    );
  }
}

class GreenInfoBox extends StatelessWidget {
  final String text;

  const GreenInfoBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Mycolor.ptscolor,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(15),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.lock, color: Mycolor.green, size: 15),
            wSized10,
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Mycolor.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
