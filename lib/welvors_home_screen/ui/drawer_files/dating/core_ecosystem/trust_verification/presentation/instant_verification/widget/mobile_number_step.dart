import '../../../export.dart';

class MobileNumberStep extends StatelessWidget {
  const MobileNumberStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PinkInfoBox(
          text:
              '🔐 Sign in to DigiLocker with the mobile number linked to your Aadhaar.',
        ),

        hSized20,

        const Text(
          'DIGILOCKER MOBILE NUMBER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9B9499),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          keyboardType: TextInputType.number,
          maxLength: 10,
          cursorColor: const Color(0xFF9A9298),

          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9A9298),
          ),

          decoration: InputDecoration(
            hintText: '98765 43210',

            hintStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9A9298),
            ),

            // Remove character counter
            counterText: '',

            filled: true,
            fillColor: Colors.white,

            // Exact spacing like screenshot
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 13,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF0E8E8), width: 2),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF0E8E8), width: 2),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Mycolor.pink2, width: 2),
            ),
          ),

          onChanged: (value) {
            context.read<InstantVerificationBloc>().add(
              MobileNumberChanged(value),
            );
          },
        ),

        const SizedBox(height: 12),

        const Text(
          'We’ll send a one-time password from DigiLocker to this number.',
          style: TextStyle(fontSize: 12, color: Color(0xFF9A9298)),
        ),

        const SizedBox(height: 28),

        GreenInfoBox(
          text:
              'Welvors never sees your DigiLocker password — only the verified result',
        ),
      ],
    );
  }
}
