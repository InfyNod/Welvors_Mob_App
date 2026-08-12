import '../../export.dart';

import '../platinum_verification/bloc/platinum_verification_bloc.dart';
import '../platinum_verification/bloc/platinum_verification_event.dart';
import '../platinum_verification/data/platinum_verification_repository.dart';
import '../platinum_verification/platinum_verification_flow_screen.dart';

class VerificationTile extends StatelessWidget {
  final String index;
  final String title;
  final String subtitle;
  final bool verified;
  final VoidCallback? onTap;

  final Color verifiedColor;
  final Color buttonfirstColor;
  final Color buttonsecondColor;
  final Color buttontextColor;
  final Color? counttextboxcolor;
  final String? buttontext;

  const VerificationTile({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.verified,
    this.onTap,
    required this.verifiedColor,
    required this.buttonfirstColor,
    required this.buttonsecondColor,
    required this.buttontextColor,
    this.counttextboxcolor,
    this.buttontext,
  });

  bool get isUnlock => buttontext?.toLowerCase().contains('unlock') ?? false;

  void _handleButtonTap(BuildContext context) {
    // Platinum unlock button
    if (isUnlock) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => PlatinumVerificationBloc(
              repository: PlatinumVerificationRepository(),
            )..add(LoadPlatinumVerification()),
            child: const PlatinumVerificationFlowScreen(),
          ),
        ),
      );

      return;
    }

    // Normal tile action
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _handleButtonTap(context);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number Box
            Container(
              height: 37,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: counttextboxcolor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                index,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Title & Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xffb2abaf),
                    ),
                  ),
                ],
              ),
            ),

            wSized10,

            // Status Button
            InkWell(
              onTap: () {
                _handleButtonTap(context);
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        buttontext == "In Progress" ||
                            buttontext == "Verified" ||
                            isUnlock
                        ? Colors.transparent
                        : buttontextColor,
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    colors: [buttonfirstColor, buttonsecondColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.2, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (verified)
                      const Icon(Icons.check, color: Colors.white, size: 18),

                    if (verified) const SizedBox(width: 4),

                    Text(
                      buttontext ?? (verified ? "Verified" : "Verify"),
                      style: TextStyle(
                        fontSize: 12,
                        color: buttontextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
