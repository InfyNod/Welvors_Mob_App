import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/government_Id/upload_id/screens/upload_id_screen.dart';

import '../../../../../../../../services/logger_service.dart';
import '../../../export.dart';
import 'aadhaarVerifiedScreen.dart';
import 'common_bottom_button.dart';
import 'consent_step.dart';

class InstantVerificationScreen extends StatelessWidget {
  const InstantVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InstantVerificationBloc(repository: InstantVerificationRepository()),
      child: const _InstantVerificationView(),
    );
  }
}

class _InstantVerificationView extends StatelessWidget {
  const _InstantVerificationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Instant Verificaton',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),

      bottomNavigationBar:
          BlocBuilder<InstantVerificationBloc, InstantVerificationState>(
            builder: (context, state) {
              final bloc = context.read<InstantVerificationBloc>();
              // Step 2 par hi bottom button show hoga

              if (state.currentStep == 4) {
                // return SafeArea(
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         BottomButton(
                //           title: '✓ Allow & verify',
                //           onTap: state.consentAccepted
                //               ? () {
                //                   bloc.add(const AllowAndVerify());
                //                 }
                //               : null,
                //         ),
                //         hSized10,
                //         Center(
                //           child: GestureDetector(
                //             onTap: () {
                //               bloc.add(const DenyConsent());
                //             },
                //             child: Text(
                //               'Deny',
                //               style: TextStyle(
                //                 color: Mycolor.lightGreyText,
                //                 fontSize: 14,
                //                 fontWeight: FontWeight.w700,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // );
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CommonBottomButton(
                        title: '✓ Allow & verify',
                        loading:
                            state.status == InstantVerificationStatus.loading,
                        onTap: state.consentAccepted
                            ? () {
                                AppLogger.i('InstantVerificationScreen', 'BUTTON CLICKED');

                                bloc.add(const AllowAndVerify());
                              }
                            : null,
                      ),
                      hSized18,

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            bloc.add(const DenyConsent());
                          },
                          child: const Text(
                            'Deny',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9C969B),
                            ),
                          ),
                        ),
                      ),
                      hSized20,
                    ],
                  ),
                );
              }
              if (state.currentStep == 3) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BlocConsumer<
                          InstantVerificationBloc,
                          InstantVerificationState
                        >(
                          listenWhen: (previous, current) {
                            // Sirf status change hone par listener chale
                            return previous.status != current.status;
                          },
                          listener: (context, state) {
                            if (state.status ==
                                InstantVerificationStatus.loading) {
                              AppLogger.d('InstantVerificationScreen', 'OTP VERIFYING...');
                              return;
                            }

                            if (state.status ==
                                InstantVerificationStatus.success) {
                              AppLogger.i('InstantVerificationScreen', 'OTP VALID');

                              // Yahan navigation karo
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => const ConsentStep(),
                              //   ),
                              // );

                              return;
                            }

                            if (state.status ==
                                InstantVerificationStatus.failure) {
                              AppLogger.w('InstantVerificationScreen', 'OTP INVALID: ${state.errorMessage}');

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    state.errorMessage ?? 'Invalid OTP',
                                  ),
                                ),
                              );

                              return;
                            }
                          },
                          builder: (context, state) {
                            final isLoading =
                                state.status ==
                                InstantVerificationStatus.loading;

                            return BottomButton(
                              shadowColor: Mycolor.redshadow,
                              colors: [Mycolor.pink, Mycolor.pink1],
                              title: isLoading
                                  ? 'Verifying...'
                                  : 'Verify OTP →',
                              onTap: state.otp.length == 6 && !isLoading
                                  ? () {
                                      AppLogger.d(
                                        'InstantVerificationScreen',
                                        '🔥 VERIFY BUTTON CLICKED: ${state.otp}',
                                      );

                                      context
                                          .read<InstantVerificationBloc>()
                                          .add(const VerifyOtp());
                                    }
                                  : null,
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        InkWell(
                          onTap: () {
                            context.read<InstantVerificationBloc>().add(
                              const PreviousStep(),
                            );
                          },
                          child: const Center(
                            child: Text(
                              'Change number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9C969B),
                              ),
                            ),
                          ),
                        ),
                        hSized20,
                      ],
                    ),
                  ),
                );
              }

              if (state.currentStep == 2) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BottomButton(
                          shadowColor: Mycolor.redshadow,
                          colors: [Mycolor.pink, Mycolor.pink1],
                          title: 'Send OTP →',
                          onTap: () {
                            context.read<InstantVerificationBloc>().add(
                              const SendOtp(),
                            );
                          },
                        ),
                        hSized18,
                        Center(
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Upload Manually Instead',
                              style: TextStyle(
                                color: Mycolor.lightGreyText,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        // hSized20,
                      ],
                    ),
                  ),
                );
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BottomButton(
                        shadowColor: Mycolor.redshadow,
                        colors: [Mycolor.pink, Mycolor.pink1],
                        title: state.selectedDocument == null
                            ? 'Continue with Aadhaar'
                            : 'Continue with ${state.selectedDocument!.title}',
                        onTap: state.selectedDocument == null
                            ? null
                            : () {
                                context.read<InstantVerificationBloc>().add(
                                  const ContinueWithDocument(),
                                );
                              },
                      ),

                      hSized18,
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UploadIdScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Upload Manually Instead',
                            style: TextStyle(
                              color: Mycolor.lightGreyText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      // hSized20,
                    ],
                  ),
                ),
              );
            },
          ),
      body: SafeArea(
        child: BlocListener<InstantVerificationBloc, InstantVerificationState>(
          listenWhen: (previous, current) {
            return previous.status != current.status &&
                current.status == InstantVerificationStatus.aadhaarVerified;
          },
          listener: (context, state) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AadhaarVerifiedScreen(
                  title: 'Aadhaar verified',
                  subtitle:
                      'Your Aadhaar was fetched from DigiLocker and\n'
                      'verified instantly. Name & age confirmed —\n'
                      'you’re now Level 2 verified.',
                  cardbottomtext: "+ Updated instantly",
                ),
              ),
            );
          },
          child: BlocBuilder<InstantVerificationBloc, InstantVerificationState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: _StepContent(state: state),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final InstantVerificationState state;

  const _StepContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstantVerificationBloc, InstantVerificationState>(
      builder: (context, state) {
        return Column(
          children: [
            VerificationStepper(currentStep: state.currentStep),

            const SizedBox(height: 10),

            // STEP 1
            if (state.currentStep == 1)
              const DocumentStep()
            // STEP 2
            else if (state.currentStep == 2)
              const MobileNumberStep()
            // STEP 3
            else if (state.currentStep == 3)
              const OtpStep()
            // STEP 4
            else if (state.currentStep == 4)
              const ConsentStep(),
          ],
        );
      },
    );
  }
}
