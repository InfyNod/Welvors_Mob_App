import '../../../export.dart';
import '../../instant_verification/widget/aadhaarVerifiedScreen.dart';

import 'bloc/education_bloc.dart';
import 'bloc/education_event.dart';
import 'bloc/education_state.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class EducationManuallyScreen extends StatelessWidget {
  const EducationManuallyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EducationBloc_manually(),
      child: const _EducationView(),
    );
  }
}

class _EducationView extends StatelessWidget {
  const _EducationView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<EducationBloc_manually, EducationState_manually>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },

      listener: (context, state) {
        // =========================
        // SUCCESS
        // =========================
        if (state.status == EducationStatus.success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AadhaarVerifiedScreen(
                icon: Icon(Icons.access_time_rounded),
                title: "Education submitted",
                subtitle:
                    "Education details submitted. We’ll review and notify you within 24–48 hours.",
                cardbottomtext: "Pending review · score updates on approval",
                score: 20,
              ),
            ),
          );
        }

        // =========================
        // FAILURE
        // =========================
        if (state.status == EducationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Something went wrong'),
            ),
          );
        }
      },

      child: Scaffold(
        backgroundColor: Mycolor.white,

        // =========================================================
        // APP BAR
        // =========================================================
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
            'Education',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),

        // =========================================================
        // BOTTOM BUTTON
        // =========================================================
        bottomNavigationBar:
            BlocBuilder<EducationBloc_manually, EducationState_manually>(
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
                                  AppLogger.d('EducationManuallyScreen', 'Submit button clicked');

                                  context.read<EducationBloc_manually>().add(
                                    const SubmitEducation(),
                                  );
                                }
                              : null,
                        ),

                        hSized15,

                        // =================================================
                        // USE INSTANT INSTEAD
                        // =================================================
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to instant verification
                            },
                            child: const Text(
                              'Use instant instead',
                              style: TextStyle(
                                color: Color(0xFF9D969C),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        hSized10,
                      ],
                    ),
                  ),
                );
              },
            ),

        // =========================================================
        // BODY
        // =========================================================
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<EducationBloc_manually, EducationState_manually>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,

                padding: const EdgeInsets.fromLTRB(24, 10, 24, 15),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // INFO CARD
                    // =================================================
                    _infoCard(),

                    hSized20,

                    // =================================================
                    // COLLEGE / UNIVERSITY
                    // =================================================
                    _label('COLLEGE / UNIVERSITY'),

                    hSized10,

                    EducationTextField(
                      hintText: "e.g. St. Xavier’s College, Mumbai",
                      onChanged: (value) {
                        context.read<EducationBloc_manually>().add(
                          CollegeChanged(value),
                        );
                      },
                    ),

                    hSized20,

                    // =================================================
                    // DEGREE
                    // =================================================
                    _label('DEGREE'),

                    hSized10,

                    EducationTextField(
                      hintText: 'e.g. B.Com (Hons)',
                      onChanged: (value) {
                        context.read<EducationBloc_manually>().add(
                          DegreeChanged(value),
                        );
                      },
                    ),

                    hSized20,

                    // =================================================
                    // YEAR
                    // =================================================
                    _label('YEAR OF PASSING'),

                    hSized10,

                    EducationTextField(
                      hintText: '2020',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        context.read<EducationBloc_manually>().add(
                          YearChanged(value),
                        );
                      },
                    ),

                    hSized20,

                    // =================================================
                    // UPLOAD
                    // =================================================
                    _label('UPLOAD DEGREE / MARKSHEET'),

                    hSized10,

                    EducationUploadBox(
                      file: state.file,
                      onTap: () {
                        context.read<EducationBloc_manually>().add(
                          const UploadDocument(),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // CONFIRMATION
                    // =================================================
                    EducationConfirmBox(
                      value: state.isConfirmed,
                      onChanged: (value) {
                        context.read<EducationBloc_manually>().add(
                          ConfirmationChanged(value),
                        );
                      },
                    ),

                    // hSized10,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // INFO CARD
  // ===============================================================

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        '🎓 Add your highest qualification. We verify with your college / university.',
        style: TextStyle(
          color: Mycolor.pink3,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ===============================================================
  // LABEL
  // ===============================================================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Color(0xFF9C969A),
        ),
      ),
    );
  }
}
