import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/model/membership_plan_model.dart';

import '../data/membership_plan_repository.dart';
import 'membership_plan_event.dart';
import 'membership_plan_state.dart';

class MembershipPlanBloc
    extends Bloc<MembershipPlanEvent, MembershipPlanState> {
  final MembershipPlanRepository _repository;

  MembershipPlanBloc({required MembershipPlanRepository repository})
    : _repository = repository,
      super(const MembershipPlanState()) {
    on<LoadMembershipPlans>(_onLoadPlans);
    on<SelectMembershipTier>(_onSelectTier);
    on<SelectPlanDuration>(_onSelectDuration);
  }

  Future<void> _onLoadPlans(
    LoadMembershipPlans event,
    Emitter<MembershipPlanState> emit,
  ) async {
    emit(state.copyWith(status: MembershipPlanStatus.loading));

    try {
      final plans = await _repository.fetchPlans();

      final selectedPlan = plans.firstWhere(
        (plan) => plan.tier == event.initialTier,
      );

      final selectedDurationIndex = switch (event.initialTier) {
        MembershipTier.premiumPlus => 1,
        MembershipTier.vip => 2,
        MembershipTier.elite => 2,
      };

      emit(
        state.copyWith(
          status: MembershipPlanStatus.success,
          plans: plans,
          selectedTier: event.initialTier,
          selectedPlan: selectedPlan,
          selectedDurationIndex: selectedDurationIndex,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MembershipPlanStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSelectTier(
    SelectMembershipTier event,
    Emitter<MembershipPlanState> emit,
  ) {
    final selectedPlan = state.plans.firstWhere(
      (plan) => plan.tier == event.tier,
    );

    int durationIndex = 0;

    switch (event.tier) {
      case MembershipTier.premiumPlus:
        durationIndex = 1;
        break;

      case MembershipTier.vip:
        durationIndex = 2;
        break;

      case MembershipTier.elite:
        durationIndex = 2;
        break;
    }

    emit(
      state.copyWith(
        selectedTier: event.tier,
        selectedPlan: selectedPlan,
        selectedDurationIndex: durationIndex,
      ),
    );
  }

  void _onSelectDuration(
    SelectPlanDuration event,
    Emitter<MembershipPlanState> emit,
  ) {
    emit(state.copyWith(selectedDurationIndex: event.index));
  }
}
