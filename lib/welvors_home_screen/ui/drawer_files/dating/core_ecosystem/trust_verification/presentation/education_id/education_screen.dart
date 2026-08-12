import '../../bloc/Education/education_bloc.dart';
import '../../bloc/Education/education_state.dart';
import '../../export.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

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
          "Education ID",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<EducationBloc, EducationState>(
        builder: (context, state) {
          if (state is GovernmentVerificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EducationLoaded) {
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
                        color: Mycolor.pink3,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  hSized15,

                  Text(
                    data.bannertitle,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),

                  hSized10,

                  ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: data.methods.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (_, index) {
                      return EducationMethodCard(
                        method: data.methods[index],
                        onTap: () {
                          debugPrint(data.methods[index].id);
                          if (data.methods[index].id.toString() == "Instant") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InstantEducationScreen(),
                              ),
                            );
                          } else if (data.methods[index].id.toString() ==
                              "manual_edu") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EducationManuallyScreen(),
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
