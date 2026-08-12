import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../export.dart';
import '../../../instant_verification/widget/aadhaarVerifiedScreen.dart';
import '../widgets/professional_info_box.dart';

import '../bloc/professional_bloc.dart';
import '../bloc/professional_event.dart';
import '../bloc/professional_state.dart';
import '../widgets/professional_button.dart';
import '../widgets/professional_code_input.dart';

class ProfessionalCodeScreen extends StatelessWidget {
  const ProfessionalCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfessionalBloc, ProfessionalState>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },

      listener: (context, state) {
        // ==========================================
        // SUCCESS
        // ==========================================

        if (state.status == ProfessionalStatus.success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AadhaarVerifiedScreen(
                title: 'Professional verified',
                subtitle:
                    'Your work email was verified — your company & role are now confirmed.',
                score: 30,
                cardbottomtext: '+ Updated instantly',
              ),
            ),
          );
        }

        // ==========================================
        // FAILURE
        // ==========================================

        if (state.status == ProfessionalStatus.failure && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },

      child: Scaffold(
        backgroundColor: Mycolor.white,

        // ==========================================
        // BOTTOM BUTTON
        // ==========================================
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 10,
            bottom: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<ProfessionalBloc, ProfessionalState>(
                builder: (context, state) {
                  return ProfessionalButton(
                    title: 'Verify code',
                    loading: state.status == ProfessionalStatus.verifying,

                    onPressed: state.status == ProfessionalStatus.verifying
                        ? null
                        : () {
                            context.read<ProfessionalBloc>().add(
                              VerifyCodeEvent(
                                email: state.email,
                                code: state.code,
                              ),
                            );
                          },
                  );
                },
              ),

              TextButton(
                onPressed: () {
                  context.read<ProfessionalBloc>().add(ChangeEmailEvent());

                  Navigator.pop(context);
                },
                child: Text(
                  'Change email',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ==========================================
        // APP BAR
        // ==========================================
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black87,
                  size: 16,
                ),
              ),
            ),
          ),
          title: const Text(
            'Professional',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),

        // ==========================================
        // BODY
        // ==========================================
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 18),
            child: Column(
              children: [
                const ProfessionalInfoBox(
                  icon: Icons.mark_email_read_outlined,
                  text: 'Enter the 6-digit code sent to your work email.',
                ),

                const SizedBox(height: 30),

                ProfessionalCodeInput(
                  onChanged: (code) {
                    context.read<ProfessionalBloc>().add(
                      CodeChangedEvent(code),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ========================================
                // RESEND
                // ========================================
                BlocBuilder<ProfessionalBloc, ProfessionalState>(
                  builder: (context, state) {
                    final seconds = state.resendSeconds;

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            'Didn’t get it? ',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 19,
                            ),
                          ),

                          GestureDetector(
                            onTap: seconds == 0
                                ? () {
                                    context.read<ProfessionalBloc>().add(
                                      ResendCodeEvent(state.email),
                                    );
                                  }
                                : null,
                            child: Text(
                              seconds == 0
                                  ? 'Resend code'
                                  : 'Resend in 0:${seconds.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Color(0xFFC9155D),
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
