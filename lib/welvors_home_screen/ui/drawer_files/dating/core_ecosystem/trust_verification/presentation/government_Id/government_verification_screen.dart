import '../../../../../../../services/logger_service.dart';
import '../../export.dart';
import 'upload_id/screens/upload_id_screen.dart';
import '../instant_verification/widget/instant_verification_screen.dart';

class GovernmentVerificationScreen extends StatelessWidget {
  const GovernmentVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
          "Government ID",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body:
          BlocBuilder<GovernmentVerificationBloc, GovernmentVerificationState>(
            builder: (context, state) {
              if (state is GovernmentVerificationLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is GovernmentVerificationLoaded) {
                final data = state.response;

                return SingleChildScrollView(
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
                            color: Mycolor.pink2,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      hSized15,

                      const Text(
                        "Choose verification method",
                        style: TextStyle(
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
                        separatorBuilder: (_, __) => const SizedBox(height: 18),
                        itemBuilder: (_, index) {
                          return GovernmentMethodCard(
                            method: data.methods[index],
                            onTap: () {
                              AppLogger.d('GovernmentVerificationScreen', data.methods[index].id.toString());
                              if (data.methods[index].id ==
                                  "instant_verification") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InstantVerificationScreen(),
                                  ),
                                );
                              } else if (data.methods[index].id ==
                                  "upload_manual") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const UploadIdScreen(),
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

              return const SizedBox();
            },
          ),
    );
  }
}
