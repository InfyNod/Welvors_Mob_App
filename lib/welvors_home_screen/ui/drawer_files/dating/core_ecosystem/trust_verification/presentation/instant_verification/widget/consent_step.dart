import '../../../export.dart';

import 'ConsentCheckbox.dart';
import 'constant_header.dart';
import 'sharedDataCard.dart';

class ConsentStep extends StatelessWidget {
  const ConsentStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstantVerificationBloc, InstantVerificationState>(
      builder: (context, state) {
        final bloc = context.read<InstantVerificationBloc>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ConsentHeader(),

            const SizedBox(height: 28),

            const Text(
              'Data that will be shared',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF29242D),
              ),
            ),

            const SizedBox(height: 16),

            const SharedDataCard(),

            const SizedBox(height: 24),

            ConsentCheckbox(
              accepted: state.consentAccepted,
              onTap: () {
                bloc.add(const ToggleConsent());
              },
            ),
          ],
        );
      },
    );
  }
}
