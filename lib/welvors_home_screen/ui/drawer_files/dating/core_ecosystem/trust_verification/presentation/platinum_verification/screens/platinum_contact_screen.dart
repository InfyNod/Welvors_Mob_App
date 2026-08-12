import '../bloc/platinum_verification_bloc.dart';
import '../bloc/platinum_verification_event.dart';
import '../bloc/platinum_verification_state.dart';
import '../widgets/platinum_widgets.dart';
import '../../../export.dart';

class PlatinumContactScreen extends StatelessWidget {
  final bool? screencall;
  const PlatinumContactScreen({super.key, this.screencall});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlatinumVerificationBloc>();

    return Scaffold(
      backgroundColor: Mycolor.white,
      appBar: PlatinumAppBar(
        action: screencall,
        title: 'Emergency Contact',
        trailing: '3 of 3',
        onBack: () {
          if (screencall == true) {
            bloc.add(const GoToStep(2));
          } else {
            Navigator.pop(context);
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 18, bottom: 5, right: 18, top: 10),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomAction(
              text: '✓ Complete Verification',
              onPressed: () {
                if (screencall == true) bloc.add(SubmitCurrentStep());
              },
              secondaryText: 'Save & do later',
              onSecondary: () {
                if (screencall == true) bloc.add(SaveForLater());
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
              children: [
                const InfoBox(
                  icon: '📞',
                  text:
                      'A trusted person registered with us for your safety. They are only contacted in genuine emergencies.',
                  type: InfoType.pink,
                ),

                const SizedBox(height: 30),

                const FieldLabel('CONTACT’S FULL NAME'),

                BlocBuilder<
                  PlatinumVerificationBloc,
                  PlatinumVerificationState
                >(
                  builder: (_, state) {
                    return TextFieldBox(
                      value: state.contactName,
                      onChanged: (value) {
                        bloc.add(UpdateContactName(value));
                      },
                    );
                  },
                ),

                const SizedBox(height: 26),

                const FieldLabel('RELATIONSHIP TO YOU'),

                BlocBuilder<
                  PlatinumVerificationBloc,
                  PlatinumVerificationState
                >(
                  builder: (_, state) {
                    return TextFieldBox(
                      value: state.relationship,
                      onChanged: (value) {
                        bloc.add(UpdateRelationship(value));
                      },
                    );
                  },
                ),

                const SizedBox(height: 26),

                const FieldLabel('CONTACT’S MOBILE NUMBER'),

                BlocBuilder<
                  PlatinumVerificationBloc,
                  PlatinumVerificationState
                >(
                  builder: (_, state) {
                    return TextFieldBox(
                      value: state.contactMobile,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        bloc.add(UpdateContactMobile(value));
                      },
                    );
                  },
                ),

                const SizedBox(height: 26),

                const FieldLabel('CONTACT’S EMAIL (OPTIONAL)'),

                BlocBuilder<
                  PlatinumVerificationBloc,
                  PlatinumVerificationState
                >(
                  builder: (_, state) {
                    return TextFieldBox(
                      value: state.contactEmail,
                      hint: 'e.g. meera@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        bloc.add(UpdateContactEmail(value));
                      },
                    );
                  },
                ),

                const SizedBox(height: 26),

                const FieldLabel(
                  'DOES YOUR CONTACT KNOW THEY’VE BEEN REGISTERED?',
                ),

                BlocBuilder<
                  PlatinumVerificationBloc,
                  PlatinumVerificationState
                >(
                  builder: (_, state) {
                    return Column(
                      children: [
                        RadioChoice(
                          title: 'Yes, they are aware and have consented',
                          selected: state.contactConsent,
                          onTap: () {
                            bloc.add(const SetContactConsent(true));
                          },
                        ),
                        const SizedBox(height: 12),
                        RadioChoice(
                          title: 'No — I need to inform them first',
                          selected: !state.contactConsent,
                          onTap: () {
                            bloc.add(const SetContactConsent(false));
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
