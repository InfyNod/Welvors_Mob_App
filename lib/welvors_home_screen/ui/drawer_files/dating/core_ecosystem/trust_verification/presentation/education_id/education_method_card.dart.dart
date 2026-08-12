import '../../export.dart';

class EducationMethodCard extends StatelessWidget {
  final VerificationMethod method;
  final VoidCallback onTap;

  const EducationMethodCard({
    super.key,
    required this.method,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
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
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: method.iconBackground,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(method.icon, style: const TextStyle(fontSize: 28)),
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,

                    children: [
                      Text(
                        method.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      wSized10,
                      if (method.recommended)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffE9F8EF),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            method.type,
                            style: TextStyle(
                              color: Color(0xff30A05B),
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // const SizedBox(height: 6),
                  Text(
                    method.subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Mycolor.lightGreyText1,
                    ),
                  ),
                ],
              ),
            ),

            if (method.arrow) const SizedBox(width: 12),

            if (method.arrow)
              const Icon(Icons.chevron_right, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}
