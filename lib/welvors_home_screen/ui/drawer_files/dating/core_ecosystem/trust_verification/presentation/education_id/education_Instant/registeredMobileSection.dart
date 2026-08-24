import '../../../export.dart';

class RegisteredMobileSection extends StatelessWidget {
  const RegisteredMobileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EducationBloc_instant, EducationState_instant>(
      builder: (context, state) {
        final hasError =
            state.status == EducationStatus.failure &&
            state.errorMessage != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 3),
              child: Text(
                'REGISTERED MOBILE / DIGILOCKER',
                style: TextStyle(
                  color: Color(0xFF999399),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              keyboardType: TextInputType.number,

              // Indian mobile number = 10 digits
              maxLength: 10,

              cursorColor: const Color(0xFF9A9298),

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Mycolor.black,
              ),

              decoration: InputDecoration(
                hintText: '98765 43210',

                hintStyle: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9A9298),
                ),

                counterText: '',

                filled: true,
                fillColor: Colors.white,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : const Color(0xFFF0E8E8),
                    width: 2,
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : const Color(0xFFF0E8E8),
                    width: 2,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : Mycolor.pink2,
                    width: 2,
                  ),
                ),
              ),

              onChanged: (value) {
                context.read<EducationBloc_instant>().add(
                  MobileNumberChanged_instant(value),
                );
              },
            ),

            // ==============================
            // ERROR MESSAGE
            // ==============================
            if (hasError) ...[
              const SizedBox(height: 7),

              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            hSized8,

            const Text(
              'Used to fetch your academic records securely.',
              style: TextStyle(
                color: Color(0xFF999399),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }
}
