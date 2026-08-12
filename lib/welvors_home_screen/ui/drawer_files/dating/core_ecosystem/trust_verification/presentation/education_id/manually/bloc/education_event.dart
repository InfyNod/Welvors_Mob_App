import 'package:flutter/foundation.dart';

@immutable
abstract class EducationEvent_manually {
  const EducationEvent_manually();
}

class CollegeChanged extends EducationEvent_manually {
  final String value;

  const CollegeChanged(this.value);
}

class DegreeChanged extends EducationEvent_manually {
  final String value;

  const DegreeChanged(this.value);
}

class YearChanged extends EducationEvent_manually {
  final String value;

  const YearChanged(this.value);
}

class ConfirmationChanged extends EducationEvent_manually {
  final bool value;

  const ConfirmationChanged(this.value);
}

class UploadDocument extends EducationEvent_manually {
  const UploadDocument();
}

class SubmitEducation extends EducationEvent_manually {
  const SubmitEducation();
}
