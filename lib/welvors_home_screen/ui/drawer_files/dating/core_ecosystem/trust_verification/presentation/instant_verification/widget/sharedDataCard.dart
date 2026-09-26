import '../../../export.dart';

class SharedDataCard extends StatelessWidget {
  const SharedDataCard({super.key});

  @override
  Widget build(BuildContext context) {
    const items = ['Name', 'Photo', 'Date of birth', 'Gender'];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++)
            Column(
              children: [
                _SharedDataItem(title: items[i]),
                if (i != items.length - 1)
                  const Divider(height: 1, color: Color(0xFFEAE4E7)),
              ],
            ),
        ],
      ),
    );
  }
}

class _SharedDataItem extends StatelessWidget {
  final String title;

  const _SharedDataItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          wSized18,
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Mycolor.greenLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check, color: Mycolor.green, size: 22),
          ),

          const SizedBox(width: 20),

          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF29242D),
            ),
          ),
        ],
      ),
    );
  }
}
