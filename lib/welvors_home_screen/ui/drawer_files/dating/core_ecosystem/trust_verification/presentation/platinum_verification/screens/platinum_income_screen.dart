import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/platinum_verification_bloc.dart';
import '../bloc/platinum_verification_event.dart';
import '../bloc/platinum_verification_state.dart';
import '../widgets/platinum_widgets.dart';
import '../../../export.dart';

class PlatinumIncomeScreen extends StatelessWidget {
  const PlatinumIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlatinumVerificationBloc>();

    const brackets = [
      '5–10 LPA',
      '10–20 LPA',
      '20–50 LPA',
      '50 LPA–1 Cr',
      '1 Cr+',
    ];

    const proofs = ['Latest salary slip', 'Form-16', 'ITR acknowledgement'];

    return Scaffold(
      backgroundColor: Mycolor.white,
      appBar: PlatinumAppBar(
        title: 'Income Verification',
        trailing: '2 of 3',
        onBack: () {
          bloc.add(const GoToStep(1));
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

                  enabled: state.incomeConfirmed,

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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              children: [
                const InfoBox(
                  icon: '💰',
                  text:
                      'Confirm your income bracket. Only the bracket is shown on your profile — never the exact figure.',
                  type: InfoType.pink,
                ),

                hSized20,

                const SectionLabel('ANNUAL INCOME BRACKET'),

                BlocBuilder<
                  PlatinumVerificationBloc,
                  PlatinumVerificationState
                >(
                  builder: (_, state) {
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: brackets.map((item) {
                        return ChoiceChipButton(
                          text: item,
                          selected: state.incomeBracket == item,
                          onTap: () {
                            bloc.add(SelectIncomeBracket(item));
                          },
                        );
                      }).toList(),
                    );
                  },
                ),

                hSized20,

                const SectionLabel('UPLOAD PROOF'),

                BlocBuilder<
                  PlatinumVerificationBloc,
                  PlatinumVerificationState
                >(
                  builder: (_, state) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: proofs.map((item) {
                        return ChoiceChipButton(
                          text: item,
                          selected: state.incomeProof == item,
                          onTap: () {
                            bloc.add(SelectIncomeProof(item));
                          },
                        );
                      }).toList(),
                    );
                  },
                ),

                hSized20,

                UploadProofBox(),
                hSized14,
                const InfoBox(
                  icon: '⏱',
                  text:
                      'Processing takes 24–48 hours. You’ll get a notification once this step is complete.',
                  type: InfoType.purple,
                ),

                const SizedBox(height: 12),

                BlocBuilder<
                  PlatinumVerificationBloc,
                  PlatinumVerificationState
                >(
                  builder: (_, state) {
                    return ConsentBox(
                      checked: state.incomeConfirmed,
                      text:
                          'I confirm these details are accurate. False information leads to removal.',
                      onChanged: (value) {
                        bloc.add(SetIncomeConfirmation(value));
                      },
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
