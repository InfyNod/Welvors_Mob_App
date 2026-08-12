import 'package:equatable/equatable.dart';
import '../../Model/trust_response_model.dart';

abstract class TrustState extends Equatable {
  const TrustState();

  @override
  List<Object?> get props => [];
}

class TrustInitial extends TrustState {
  const TrustInitial();
}

class TrustLoading extends TrustState {
  const TrustLoading();
}

class TrustLoaded extends TrustState {
  final TrustResponseModel data;

  const TrustLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class TrustError extends TrustState {
  final String message;

  const TrustError(this.message);

  @override
  List<Object?> get props => [message];
}
