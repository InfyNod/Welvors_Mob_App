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
