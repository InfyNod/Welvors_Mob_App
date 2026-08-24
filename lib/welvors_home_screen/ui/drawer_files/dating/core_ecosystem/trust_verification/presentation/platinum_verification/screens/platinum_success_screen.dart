import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/data/trust_repository.dart';
import '../../trust_verfication/home.dart';

import '../bloc/platinum_verification_bloc.dart';
import '../bloc/platinum_verification_event.dart';
import '../widgets/platinum_widgets.dart';
import '../../../export.dart' hide TrustScoreCard;

class PlatinumSuccessScreen extends StatelessWidget {
  const PlatinumSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Mycolor.white,

      // bottomNavigationBar: Column(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     SizedBox(
      //       height: 60,
      //       width: ,
      //       child: ElevatedButton(
      //         onPressed: () {
      //           context.read<PlatinumVerificationBloc>().add(const GoToStep(0));
      //         },
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Mycolor.dark,
      //           foregroundColor: Colors.white,
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(22),
      //           ),
      //         ),
      //         child: const Text(
      //           '← Back to Trust Centre',
      //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 18, bottom: 5, right: 18, top: 10),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomButton(
              shadowColor: Mycolor.blueshadow,
              colors: [Mycolor.darkPurple, Mycolor.darkPurple],
              title: '← Back to Trust Centre',
              onTap: () {
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == '/TrustVerificationScreen',
                );
              },
            ),
            hSized30,
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              children: [
                const Text(
                  '👑',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 64),
                ),

                const SizedBox(height: 25),

                const Text(
                  'You’re Platinum Verified!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Mycolor.text,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Your verification is under review. You’ll receive a notification within 24–48 hours once it’s complete.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Mycolor.darkMuted,
                  ),
                ),

                const SizedBox(height: 32),

                const TrustScoreCard(),

                const SizedBox(height: 28),

                const VerificationStatusCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
