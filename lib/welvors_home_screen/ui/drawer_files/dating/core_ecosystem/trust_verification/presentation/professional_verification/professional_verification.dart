import '../../../../../../../services/logger_service.dart';
import '../../export.dart';
import 'bloc/professional_verfication_bloc.dart';
import 'bloc/professional_verfication_state.dart';
import 'domain/repositories/professional_repository_impl.dart';
import 'presentation/bloc/professional_bloc.dart';
import 'presentation/screens/professional_email_screen.dart';
import 'professional_manually/professional_manually_screen.dart';

class ProfessionalVerficationScreen extends StatelessWidget {
  const ProfessionalVerficationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<professional_verfication_bloc, professional_verficationState>(
        builder: (context, state) {
          if (state is GovernmentVerificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is professional_verficationLoaded) {
            final data = state.response;

            return SafeArea(
              child: Column(
                children: [
                  /// AppBar
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 40,
                            height: 40,
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

                        Expanded(
                          child: Center(
                            child: Text(
                              data.title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  /// Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: data.bannerColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              data.bannerMessage,
                              style: const TextStyle(
                                color: Mycolor.pink3,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          hSized15,

                          Text(
                            data.bannertitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          hSized10,

                          ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: data.methods.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 18),
                            itemBuilder: (_, index) {
                              final method = data.methods[index];

                              return EducationMethodCard(
                                method: method,
                                onTap: () {
                                  AppLogger.d('ProfessionalVerficationScreen', method.id);

                                  if (method.id == "Professional_Instant") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider(
                                          create: (_) => ProfessionalBloc(
                                            repository:
                                                ProfessionalRepositoryImpl(),
                                          ),
                                          child:
                                              const ProfessionalEmailScreen(),
                                        ),
                                      ),
                                    );
                                  } else if (method.id ==
                                      "manual_Professional") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ProfessionalManuallyScreen(),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
