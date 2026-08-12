import '../../../export.dart';

class OtpStep extends StatelessWidget {
  const OtpStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PinkInfoBox(
          text: '📲 Enter the 6-digit OTP sent by DigiLocker to your number.',
        ),

        const SizedBox(height: 32),

        OtpInput(),

        const SizedBox(height: 24),
      ],
    );
  }
}
