import '../../../../export.dart';

class EducationConfirmBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const EducationConfirmBox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Mycolor.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: value ? Mycolor.pink : Mycolor.color0xFFE8E1E4,
            width: 3,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: value ? Mycolor.pink : Mycolor.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: value ? Mycolor.pink : Mycolor.color0xFFE5DFE2,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),

            wSized18,

            const Expanded(
              child: Text(
                'I confirm these details are accurate. False '
                'information leads to removal.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF252126),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
