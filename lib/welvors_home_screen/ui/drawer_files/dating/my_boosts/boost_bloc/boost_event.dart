import 'package:equatable/equatable.dart';

abstract class BoostEvent extends Equatable {
  const BoostEvent();

  @override
  List<Object> get props => [];
}

class AddBoostEvent extends BoostEvent {
  final int quantity;

  const AddBoostEvent(this.quantity);

  @override
  List<Object> get props => [quantity];
}

class AddSuperBoostEvent extends BoostEvent {
  final int quantity;

  const AddSuperBoostEvent(this.quantity);

  @override
  List<Object> get props => [quantity];
}

class ConsumeBoostEvent extends BoostEvent {}

class ConsumeSuperBoostEvent extends BoostEvent {}

class FetchBoostWalletEvent extends BoostEvent {}

class FetchSuperBoostWalletEvent extends BoostEvent {}

class ActivateBoostEvent extends BoostEvent {
  final String userBoostId;

  const ActivateBoostEvent(this.userBoostId);

  @override
  List<Object> get props => [userBoostId];
}

class ActivateSuperBoostEvent extends BoostEvent {
  final String userBoostId;

  const ActivateSuperBoostEvent(this.userBoostId);

  @override
  List<Object> get props => [userBoostId];
}

class FetchBoostsDataEvent extends BoostEvent {}

class FetchSuperBoostsDataEvent extends BoostEvent {}

class FetchBoostHistoryEvent extends BoostEvent {}
