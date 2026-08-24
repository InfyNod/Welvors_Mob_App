import 'package:equatable/equatable.dart';

import '../model/membership_plan_model.dart';

abstract class MembershipPlanEvent extends Equatable {
  const MembershipPlanEvent();

  @override
  List<Object?> get props => [];
}

class LoadMembershipPlans extends MembershipPlanEvent {
  final MembershipTier initialTier;

  const LoadMembershipPlans({this.initialTier = MembershipTier.premiumPlus});

  @override
  List<Object?> get props => [initialTier];
}

class SelectMembershipTier extends MembershipPlanEvent {
  final MembershipTier tier;

  const SelectMembershipTier(this.tier);

  @override
  List<Object?> get props => [tier];
}

class SelectPlanDuration extends MembershipPlanEvent {
  final int index;

  const SelectPlanDuration(this.index);

  @override
  List<Object?> get props => [index];
}
