import '../../../export.dart';

class DocumentCard extends StatelessWidget {
  final VerificationDocument document;
  final bool selected;
  final VoidCallback onTap;

  const DocumentCard({
    super.key,
    required this.document,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,

        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),

          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: selected
                ? Border.all(color: Mycolor.pink, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    document.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            document.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        if (document.recommended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Mycolor.ptscolor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "Recommended",
                              style: TextStyle(
                                color: Mycolor.green,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      document.subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Mycolor.lightGreyText1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                selected ? Icons.radio_button_checked : Icons.chevron_right,
                color: selected
                    ? Mycolor.pink
                    : const Color(0xFF9A9298),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
