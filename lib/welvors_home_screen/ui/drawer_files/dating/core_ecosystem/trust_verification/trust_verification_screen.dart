import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/trust/trust_bloc.dart';
import 'bloc/trust/trust_event.dart';
import 'data/trust_repository.dart';

import 'bloc/government_verification/government_verification_bloc.dart';
import 'bloc/government_verification/government_verification_event.dart';
import 'data/government_verification_repository.dart';

import 'presentation/trust_verfication/home.dart';

class TrustVerificationScreen extends StatelessWidget {
  const TrustVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TrustBloc>(
          create: (_) =>
              TrustBloc(repository: TrustRepository())
                ..add(const LoadTrustData()),
        ),
        BlocProvider<GovernmentVerificationBloc>(
          create: (_) => GovernmentVerificationBloc(
            repository: GovernmentVerificationRepository(),
          )..add(LoadGovernmentVerificationEvent()),
        ),
      ],
      child: const Home(),
    );
  }
}
