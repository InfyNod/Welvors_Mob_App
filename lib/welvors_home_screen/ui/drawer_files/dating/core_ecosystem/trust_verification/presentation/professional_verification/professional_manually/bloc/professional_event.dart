abstract class ProfessionalManuallyEvent {
  const ProfessionalManuallyEvent();
}

class CompanyChanged extends ProfessionalManuallyEvent {
  final String value;

  const CompanyChanged(this.value);
}

class DesignationChanged extends ProfessionalManuallyEvent {
  final String value;

  const DesignationChanged(this.value);
}

class WorkEmailChanged extends ProfessionalManuallyEvent {
  final String value;

  const WorkEmailChanged(this.value);
}

class ConfirmationChanged extends ProfessionalManuallyEvent {
  final bool value;

  const ConfirmationChanged(this.value);
}

class UploadProfessionalDocument extends ProfessionalManuallyEvent {
  const UploadProfessionalDocument();
}

class SubmitProfessional extends ProfessionalManuallyEvent {
  const SubmitProfessional();
}
