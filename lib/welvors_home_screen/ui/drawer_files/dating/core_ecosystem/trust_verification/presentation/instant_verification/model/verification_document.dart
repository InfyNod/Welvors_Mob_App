enum VerificationDocumentType { aadhaar, pan, drivingLicence }

class VerificationDocument {
  final VerificationDocumentType type;
  final String title;
  final String subtitle;
  final String icon;
  final bool recommended;

  const VerificationDocument({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.recommended = false,
  });
}
