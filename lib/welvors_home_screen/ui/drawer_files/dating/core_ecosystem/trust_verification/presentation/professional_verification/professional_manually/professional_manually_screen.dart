import '../../../../../../../../services/logger_service.dart';
import '../../../export.dart';
import '../../instant_verification/widget/aadhaarVerifiedScreen.dart';
import 'bloc/professional_event.dart';
import 'bloc/professional_state.dart';
import 'professional_confirm_box.dart';
import 'professional_submit_button.dart';
import 'professional_text_field.dart';
import 'professional_upload_box.dart';

import 'bloc/professional_manually_bloc.dart';

class ProfessionalManuallyScreen extends StatelessWidget {
  const ProfessionalManuallyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfessionalManuallyBloc(),
      child: const _ProfessionalView(),
    );
  }
}

class _ProfessionalView extends StatelessWidget {
  const _ProfessionalView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfessionalManuallyBloc, ProfessionalManuallyState>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },

      listener: (context, state) {
        // =========================
        // SUCCESS
        // =========================
        if (state.status == ProfessionalStatus.success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AadhaarVerifiedScreen(
                title: "Professional submitted",
                subtitle:
                    "Professional details submitted. We’ll review and notify you within 24–48 hours.",

                score: 30,
                cardbottomtext: "Pending review · score updates on approval",
              ),
            ),
          );
        }

        // =========================
        // FAILURE
        // =========================
        if (state.status == ProfessionalStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Something went wrong'),
            ),
          );
        }
      },

      child: Scaffold(
        backgroundColor: Mycolor.white,

        // =====================================================
        // APP BAR
        // =====================================================
        appBar: AppBar(
          backgroundColor: Mycolor.white,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Mycolor.white,

          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
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

        // =====================================================
        // BOTTOM BUTTON
        // =====================================================
        bottomNavigationBar:
            BlocBuilder<ProfessionalManuallyBloc, ProfessionalManuallyState>(
              builder: (context, state) {
                return SafeArea(
                  top: false,
                  child: Container(
                    color: Mycolor.white,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EducationSubmitButton(
                          title: 'Submit for review',
                          onTap: state.isConfirmed
                              ? () {
                                  AppLogger.i('ProfessionalManuallyScreen', 'Submit button clicked');

                                  context.read<ProfessionalManuallyBloc>().add(
                                    const SubmitProfessional(),
                                  );
                                }
                              : null,
                        ),

                        hSized15,

                        // =========================================
                        // USE INSTANT INSTEAD
                        // =========================================
                        GestureDetector(
                          onTap: () {
                            // Instant verification
                          },
                          child: const Center(
                            child: Text(
                              'Use instant instead',
                              style: TextStyle(
                                color: Color(0xFF9D969C),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        // hSized10,
                      ],
                    ),
                  ),
                );
              },
            ),

        // =====================================================
        // BODY
        // =====================================================
        body: SafeArea(
          bottom: false,
          child:
              BlocBuilder<ProfessionalManuallyBloc, ProfessionalManuallyState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),

                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,

                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =================================================
                        // INFO CARD
                        // =================================================
                        _infoCard(),

                        hSized30,

                        // =================================================
                        // COMPANY
                        // =================================================
                        _label('COMPANY / EMPLOYER'),

                        hSized10,

                        ProfessionalTextField(
                          hintText: 'e.g. Infosys Ltd',
                          onChanged: (value) {
                            context.read<ProfessionalManuallyBloc>().add(
                              CompanyChanged(value),
                            );
                          },
                        ),

                        hSized20,

                        // =================================================
                        // DESIGNATION
                        // =================================================
                        _label('DESIGNATION'),

                        hSized10,

                        ProfessionalTextField(
                          hintText: 'e.g. Senior Product Manager',
                          onChanged: (value) {
                            context.read<ProfessionalManuallyBloc>().add(
                              DesignationChanged(value),
                            );
                          },
                        ),

                        hSized20,

                        // =================================================
                        // WORK EMAIL
                        // =================================================
                        _label('WORK EMAIL (OPTIONAL)'),

                        hSized10,

                        ProfessionalTextField(
                          hintText: 'you@company.com',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            context.read<ProfessionalManuallyBloc>().add(
                              WorkEmailChanged(value),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Speeds up verification.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9D969C),
                          ),
                        ),

                        hSized20,

                        // =================================================
                        // UPLOAD PROOF
                        // =================================================
                        _label('UPLOAD PROOF'),

                        hSized10,

                        ProfessionalUploadBox(
                          file: state.file,
                          onTap: () {
                            context.read<ProfessionalManuallyBloc>().add(
                              const UploadProfessionalDocument(),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // =================================================
                        // CONFIRMATION
                        // =================================================
                        ProfessionalConfirmBox(
                          value: state.isConfirmed,
                          onChanged: (value) {
                            context.read<ProfessionalManuallyBloc>().add(
                              ConfirmationChanged(value),
                            );
                          },
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }

  // =============================================================
  // INFO CARD
  // =============================================================

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5F0),
        borderRadius: BorderRadius.circular(19),
      ),
      child: const Text(
        '💼 Confirm where you work. Your company name shows on your profile; salary never does.',
        style: TextStyle(
          color: Mycolor.pink3,
          fontSize: 15,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =============================================================
  // LABEL
  // =============================================================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Color(0xFF9C969A),
        ),
      ),
    );
  }
}
