import 'package:equatable/equatable.dart';

import '../model/membership_plan_model.dart';

enum MembershipPlanStatus { initial, loading, success, failure }

class MembershipPlanState extends Equatable {
  final MembershipPlanStatus status;
  final List<MembershipPlanModel> plans;
  final MembershipTier selectedTier;
  final MembershipPlanModel? selectedPlan;
  final int selectedDurationIndex;
  final String errorMessage;

  const MembershipPlanState({
    this.status = MembershipPlanStatus.initial,
    this.plans = const [],
    this.selectedTier = MembershipTier.premiumPlus,
    this.selectedPlan,
    this.selectedDurationIndex = 0,
    this.errorMessage = '',
  });

  MembershipPlanState copyWith({
    MembershipPlanStatus? status,
    List<MembershipPlanModel>? plans,
    MembershipTier? selectedTier,
    MembershipPlanModel? selectedPlan,
    int? selectedDurationIndex,
    String? errorMessage,
  }) {
    return MembershipPlanState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      selectedTier: selectedTier ?? this.selectedTier,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      selectedDurationIndex:
          selectedDurationIndex ?? this.selectedDurationIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    plans,
    selectedTier,
    selectedPlan,
    selectedDurationIndex,
    errorMessage,
  ];
}
