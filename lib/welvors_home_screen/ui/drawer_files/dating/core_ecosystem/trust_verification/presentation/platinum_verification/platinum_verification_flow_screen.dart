import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/platinum_verification_bloc.dart';
import 'bloc/platinum_verification_state.dart';

import 'screens/platinum_payment_screen.dart';
import 'screens/platinum_background_screen.dart';
import 'screens/platinum_income_screen.dart';
import 'screens/platinum_contact_screen.dart';
import 'screens/platinum_success_screen.dart';

class PlatinumVerificationFlowScreen extends StatelessWidget {
  const PlatinumVerificationFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatinumVerificationBloc, PlatinumVerificationState>(
      buildWhen: (previous, current) {
        return previous.step != current.step ||
            previous.status != current.status;
      },
      builder: (context, state) {
        switch (state.step) {
          case 0:
            return const PlatinumPaymentScreen();

          case 1:
            return const PlatinumBackgroundScreen();

          case 2:
            return const PlatinumIncomeScreen();

          case 3:
            return PlatinumContactScreen(screencall: true);

          case 4:
            return PlatinumSuccessScreen();

          default:
            return const PlatinumPaymentScreen();
        }
      },
    );
  }
}
