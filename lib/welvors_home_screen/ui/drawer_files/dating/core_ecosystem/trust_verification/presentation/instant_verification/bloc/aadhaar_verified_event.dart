import 'package:equatable/equatable.dart';

abstract class AadhaarVerifiedEvent extends Equatable {
  const AadhaarVerifiedEvent();

  @override
  List<Object?> get props => [];
}

class LoadAadhaarVerified extends AadhaarVerifiedEvent {
  const LoadAadhaarVerified();
}
