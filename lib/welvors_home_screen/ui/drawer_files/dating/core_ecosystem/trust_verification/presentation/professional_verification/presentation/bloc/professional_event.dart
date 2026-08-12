import 'package:equatable/equatable.dart';

abstract class ProfessionalEvent extends Equatable {
  const ProfessionalEvent();

  @override
  List<Object?> get props => [];
}

class SendCodeEvent extends ProfessionalEvent {
  final String email;

  const SendCodeEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyCodeEvent extends ProfessionalEvent {
  final String email;
  final String code;

  const VerifyCodeEvent({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

class ResendCodeEvent extends ProfessionalEvent {
  final String email;

  const ResendCodeEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class ChangeEmailEvent extends ProfessionalEvent {}

class EmailChangedEvent extends ProfessionalEvent {
  final String email;

  const EmailChangedEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class CodeChangedEvent extends ProfessionalEvent {
  final String code;

  const CodeChangedEvent(this.code);

  @override
  List<Object?> get props => [code];
}

class StartResendTimerEvent extends ProfessionalEvent {}

class TickResendTimerEvent extends ProfessionalEvent {}
