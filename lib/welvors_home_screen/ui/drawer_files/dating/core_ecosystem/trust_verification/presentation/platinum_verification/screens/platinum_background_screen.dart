import '../bloc/platinum_verification_bloc.dart';
import '../bloc/platinum_verification_event.dart';
import '../bloc/platinum_verification_state.dart';
import '../widgets/platinum_widgets.dart';
import '../../../export.dart';

class PlatinumBackgroundScreen extends StatelessWidget {
  const PlatinumBackgroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlatinumVerificationBloc>();

    return Scaffold(
      backgroundColor: Mycolor.white,
      appBar: PlatinumAppBar(
        title: 'Criminal Background Check',
        trailing: '1 of 3',
        onBack: () {
          bloc.add(const GoToStep(0));
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 18, bottom: 5, right: 18, top: 10),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<PlatinumVerificationBloc, PlatinumVerificationState>(
              builder: (_, state) {
                return BottomAction(
                  text: 'Submit & Continue →',

                  enabled: state.criminalAuthorized,

                  onPressed: () {
                    context.read<PlatinumVerificationBloc>().add(
                      SubmitCurrentStep(),
                    );
                  },

                  secondaryText: 'Save & do later',

                  onSecondary: () {
                    context.read<PlatinumVerificationBloc>().add(
                      SaveForLater(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              children: [
                const StepIndicator(current: 0),

                hSized25,

                const InfoBox(
                  icon: '🔍',
                  text:
                      'We check court records, FIR history, and police verification databases to ensure zero criminal history.',
                  type: InfoType.pink,
                ),

                hSized18,

                const InfoBox(
                  icon: '♙',
                  text:
                      'Your Aadhaar is already verified. We’ll run the background check using your existing verified details — no need to re-enter or re-upload anything.',
                  type: InfoType.green,
                ),

                hSized25,

                const SectionLabel('WE’LL USE THESE VERIFIED DETAILS'),

                const VerifiedDetailsCard(),

                hSized25,

                const SectionLabel('STATE OF RESIDENCE'),

                BlocBuilder<
                  PlatinumVerificationBloc,
                  PlatinumVerificationState
                >(
                  builder: (_, state) {
                    return TextFieldBox(
                      value: state.residenceState,
                      onChanged: (value) {
                        bloc.add(UpdateResidenceState(value));
                      },
                    );
                  },
                ),

                hSized8,

                const Text(
                  'Confirm your current state so we query the right police jurisdiction.',
                  style: TextStyle(color: Mycolor.muted, fontSize: 14),
                ),

                hSized18,

                BlocBuilder<
                  PlatinumVerificationBloc,
                  PlatinumVerificationState
                >(
                  builder: (_, state) {
                    return ConsentBox(
                      checked: state.criminalAuthorized,
                      text:
                          'I authorise Welvors to run a criminal background check using my verified Aadhaar details.',
                      onChanged: (value) {
                        bloc.add(SetCriminalAuthorization(value));
                      },
                    );
                  },
                ),

                hSized10,

                const InfoBox(
                  icon: '⏱',
                  text:
                      'Processing takes 24–48 hours. You’ll get a notification once this step is complete.',
                  type: InfoType.purple,
                ),
                hSized10,
              ],
            ),

            // BottomAction(
            //   text: 'Submit & Continue →',
            //   onPressed: () {
            //     bloc.add(SubmitCurrentStep());
            //   },
            //   secondaryText: 'Save & do later',
            //   onSecondary: () {
            //     bloc.add(SaveForLater());
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
