import '../../../export.dart';
import '../../instant_verification/widget/aadhaarVerifiedScreen.dart';

class InstantEducationScreen extends StatelessWidget {
  const InstantEducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EducationBloc_instant(),
      child: const _InstantEducationView(),
    );
  }
}

class _InstantEducationView extends StatelessWidget {
  const _InstantEducationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Mycolor.white,

      appBar: AppBar(
        backgroundColor: Mycolor.white,
        elevation: 0,
        surfaceTintColor: Mycolor.white,

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

        centerTitle: true,

        title: const Text(
          'Education',
          style: TextStyle(
            color: Color(0xFF211F26),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        titleSpacing: 0,
      ),

      body: SafeArea(
        child: BlocListener<EducationBloc_instant, EducationState_instant>(
          listenWhen: (previous, current) => previous.status != current.status,

          listener: (context, state) {
            // =========================
            // SUCCESS
            // =========================

            if (state.status == EducationStatus.success) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AadhaarVerifiedScreen(
                    title: 'Education verified',
                    subtitle:
                        'Your degree was verified instantly from the National Academic Depository.',
                    score: 30,
                    cardbottomtext: '+ Updated instantly',
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

          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DigiLockerInfoCard(
                          icon: '🎓',
                          title: 'National Academic Depository',
                          subtitle:
                              'Govt-backed registry of verified degrees & certificates from universities across India.',
                        ),

                        const SizedBox(height: 30),

                        const RegisteredMobileSection(),

                        const SizedBox(height: 28),

                        GreenInfoBox(
                          text:
                              'You’re always in control — nothing is fetched without your consent',
                        ),
                      ],
                    ),
                  ),
                ),

                const BottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
