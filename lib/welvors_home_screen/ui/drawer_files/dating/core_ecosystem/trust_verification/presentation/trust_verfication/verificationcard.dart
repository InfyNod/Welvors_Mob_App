import '../../../../../../../services/logger_service.dart';
import '../../bloc/Education/education_bloc.dart';
import '../../bloc/Education/education_event.dart';
import '../../data/education_repository.dart';
import '../../data/professional_verication_repository.dart';
import '../../export.dart';
import '../education_id/education_screen.dart';
import '../platinum_verification/bloc/platinum_verification_bloc.dart';
import '../platinum_verification/data/platinum_verification_repository.dart';
import '../platinum_verification/screens/platinum_contact_screen.dart';
import '../professional_verification/bloc/professional_verfication_bloc.dart';
import '../professional_verification/bloc/professional_verfication_evnt.dart';
import '../professional_verification/professional_verification.dart';

class VerificationCard extends StatelessWidget {
  const VerificationCard({super.key, required this.items, this.onVerifyItem});

  final List<VerificationItemModel> items;
  final void Function(int itemIndex)? onVerifyItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return VerificationItem(
                item: items[index],
                showDivider: index < items.length - 1,
                // onVerify: onVerifyItem == null
                //     ? null
                //     : () => onVerifyItem!(index),
                onVerify: () {
                  AppLogger.d('VerificationCard', '<<<<${items[index].buttonIds}>>>>');
                  if (items[index].buttonIds != null &&
                      items[index].buttonIds == 'government_id_verification') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => GovernmentVerificationBloc(
                            repository: GovernmentVerificationRepository(),
                          )..add(LoadGovernmentVerificationEvent()),
                          child: const GovernmentVerificationScreen(),
                        ),
                      ),
                    );
                  } else if (items[index].buttonIds == "face_verification") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FaceVerificationScreen(),
                      ),
                    );
                  } else if (items[index].buttonIds == "video_verification") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoVerificationScreen(),
                      ),
                    );
                  } else if (items[index].buttonIds ==
                      'education_verification') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) =>
                              EducationBloc(repository: EducationRepository())
                                ..add(LoadEducationEvent()),
                          child: const EducationScreen(),
                        ),
                      ),
                    );
                  } else if (items[index].buttonIds ==
                      'professional_verification') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => professional_verfication_bloc(
                            repository: ProfessionalverificationRepository(),
                          )..add(Loadprofessional_verficationEvent()),
                          child: const ProfessionalVerficationScreen(),
                        ),
                      ),
                    );
                  } else if (items[index].buttonIds == 'income_verification') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (_) => PlatinumVerificationBloc(
                            repository: PlatinumVerificationRepository(),
                          ),
                          child: PlatinumContactScreen(screencall: false),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
