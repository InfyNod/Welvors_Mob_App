import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/mycolor.dart';
import '../../../../utils/sizesboxs.dart';

import '../bloc/professional_bloc.dart';
import '../bloc/professional_event.dart';
import '../bloc/professional_state.dart';
import '../widgets/professional_button.dart';
import '../widgets/professional_info_box.dart';
import 'professional_code_screen.dart';

class ProfessionalEmailScreen extends StatefulWidget {
  const ProfessionalEmailScreen({super.key});

  @override
  State<ProfessionalEmailScreen> createState() =>
      _ProfessionalEmailScreenState();
}

class _ProfessionalEmailScreenState extends State<ProfessionalEmailScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfessionalBloc, ProfessionalState>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },
      listener: (context, state) {
        if (state.status == ProfessionalStatus.codeSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ProfessionalBloc>(),
                child: const ProfessionalCodeScreen(),
              ),
            ),
          );
        }

        if (state.status == ProfessionalStatus.failure && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },

      child: SafeArea(
        top: false,
        child: Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 10,
              bottom: 5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<ProfessionalBloc, ProfessionalState>(
                  builder: (context, state) {
                    return ProfessionalButton(
                      title: 'Send code',
                      loading: state.status == ProfessionalStatus.loading,
                      onPressed: state.status == ProfessionalStatus.loading
                          ? null
                          : () {
                              context.read<ProfessionalBloc>().add(
                                SendCodeEvent(emailController.text.trim()),
                              );
                            },
                    );
                  },
                ),

                // hSized10,
                TextButton(
                  onPressed: () {
                    // TODO: manual verification
                  },
                  child: Text(
                    'Upload manually instead',
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
          backgroundColor: Mycolor.white,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 24, 26, 18),
              child: Column(
                children: [
                  const ProfessionalInfoBox(
                    icon: Icons.mail_outline,
                    text:
                        'Enter your official company email. We’ll send a one-time code to confirm you work there.',
                  ),

                  hSized20,

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'WORK EMAIL',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // TextField(
                  //   controller: emailController,
                  //   keyboardType: TextInputType.emailAddress,
                  //   onChanged: (value) {
                  //     context.read<ProfessionalBloc>().add(
                  //       EmailChangedEvent(value),
                  //     );
                  //   },
                  //   style: const TextStyle(
                  //     fontSize: 22,
                  //     color: Color(0xFF29252D),
                  //   ),
                  //   decoration: InputDecoration(
                  //     hintText: 'you@company.com',
                  //     hintStyle: TextStyle(
                  //       fontSize: 22,
                  //       color: Colors.grey.shade500,
                  //     ),
                  //     filled: true,
                  //     fillColor: Colors.white,
                  //     contentPadding: const EdgeInsets.symmetric(
                  //       horizontal: 28,
                  //       vertical: 24,
                  //     ),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(20),
                  //       borderSide: BorderSide.none,
                  //     ),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(20),
                  //       borderSide: BorderSide(
                  //         color: Colors.grey.shade200,
                  //         width: 2,
                  //       ),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(20),
                  //       borderSide: const BorderSide(
                  //         color: Color(0xFFE91E75),
                  //         width: 2,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  TextField(
                    cursorColor: const Color(0xFF9A9298),
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      context.read<ProfessionalBloc>().add(
                        EmailChangedEvent(value),
                      );
                    },
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9A9298),
                    ),

                    decoration: InputDecoration(
                      hintText: 'you@company.com',

                      hintStyle: const TextStyle(
                        fontSize: 17,
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
                        borderSide: const BorderSide(
                          color: Color(0xFFF0E8E8),
                          width: 2,
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFF0E8E8),
                          width: 2,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Mycolor.pink2,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Personal emails (gmail, yahoo) aren’t accepted for this check.',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  hSized15,

                  const ProfessionalInfoBox(
                    icon: Icons.lock_outline,
                    success: true,
                    text:
                        'We confirm your employer domain — your inbox is never accessed',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
                  color: Colors.black.withValues(alpha: 0.04),
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
    );
  }
}
