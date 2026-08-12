import '../../../export.dart';
import 'trust_score_card.dart';
import 'verified_icon.dart';
import '../../trust_verfication/home.dart';

import '../bloc/aadhaar_verified_bloc.dart';
import '../bloc/aadhaar_verified_event.dart';
import '../bloc/aadhaar_verified_state.dart';
import '../data/aadhaar_verified_repository.dart';

class AadhaarVerifiedScreen extends StatelessWidget {
  final Icon? icon;
  final Color? iconcolor;
  final String? title;
  final String? subtitle;
  final int? score;
  final String? cardbottomtext;

  const AadhaarVerifiedScreen({
    super.key,
    this.icon,
    this.iconcolor,
    this.title,
    this.subtitle,
    this.score,
    this.cardbottomtext,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AadhaarVerifiedBloc(repository: AadhaarVerifiedRepository())
            ..add(const LoadAadhaarVerified()),
      child: _AadhaarVerifiedView(
        icon: icon,
        iconcolor: iconcolor,
        typename: title,
        typedescription: subtitle,
        score: score,
        cardbottomtext: cardbottomtext,
      ),
    );
  }
}

class _AadhaarVerifiedView extends StatelessWidget {
  final Icon? icon;
  final Color? iconcolor;
  final String? typename;
  final String? typedescription;
  final int? score;
  final String? cardbottomtext;

  const _AadhaarVerifiedView({
    this.icon,
    this.iconcolor,
    this.typename,
    this.typedescription,
    this.score,
    this.cardbottomtext,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AadhaarVerifiedBloc, AadhaarVerifiedState>(
      builder: (context, state) {
        if (state.status == AadhaarVerifiedStatus.loading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F2F4),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == AadhaarVerifiedStatus.failure) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F2F4),
            body: Center(
              child: Text(state.errorMessage ?? 'Something went wrong'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F2F4),

          // ---------------- BOTTOM BUTTON ----------------
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BottomButton(
                  shadowColor: Mycolor.blueshadow,
                  colors: [Mycolor.darkPurple, Mycolor.darkPurple],
                  title: '← Back to Trust Centre',
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Home()),
                      (route) => false,
                    );
                  },
                ),
                hSized30,
              ],
            ),
          ),

          // ---------------- BODY ----------------
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Column(
                children: [
                  hSized20,
                  // VERIFIED ICON
                  const VerifiedIcon(),

                  hSized48,

                  // TITLE
                  Text(
                    typename ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF252131),
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DESCRIPTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      typedescription ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF625D69),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // TRUST SCORE
                  TrustScoreCardAdhar(
                    score: state.trustScore,
                    scorebottomtest: cardbottomtext,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
