import '../../export.dart';

class VerificationItem extends StatelessWidget {
  const VerificationItem({
    super.key,
    required this.item,
    this.showDivider = true,
    this.onVerify,
  });

  final VerificationItemModel item;
  final bool showDivider;
  final VoidCallback? onVerify;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider) hSized10,
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: item.iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(item.icon, style: const TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.subtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        if (item.islocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xfff3f1f6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock,
                                  color: Color(0xff9a9298),
                                  size: 14,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Locked",
                                  style: TextStyle(
                                    color: Color(0xff9a9298),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (item.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xffE8F6EE),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Color(0xff27AE60),
                                  size: 14,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Done",
                                  style: TextStyle(
                                    color: Color(0xff27AE60),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (item.isVerfiyed) wSized5,
                        if (item.isVerfiyed)
                          OutlinedButton(
                            onPressed: onVerify,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(80, 34), // Width, Height
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: Color(0xFFE8DDDD),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Verify",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Color(0xFF5A5560),
                              ),
                            ),
                          ),
                      ],
                    ),
                    hSized10,
                    // if (item.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: item.ptsColor ?? const Color(0xffE8F6EE),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.points,
                            style: TextStyle(
                              color: item.ptstextcolor ?? Color(0xff27AE60),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // const SizedBox(width: 16),
            ],
          ),
        ),

        if (showDivider) hSized10,

        if (showDivider)
          Divider(color: Colors.grey.shade200, height: 1, thickness: 1),

        hSized10,
      ],
    );
  }
}
