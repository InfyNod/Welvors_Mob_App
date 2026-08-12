import 'dart:io';

import '../models/upload_id_model.dart';

abstract class UploadIdEvent {
  const UploadIdEvent();
}

class SelectIdType extends UploadIdEvent {
  final IdType idType;

  const SelectIdType(this.idType);
}

class AadhaarNumberChanged extends UploadIdEvent {
  final String value;

  const AadhaarNumberChanged(this.value);
}

class FullNameChanged extends UploadIdEvent {
  final String value;

  const FullNameChanged(this.value);
}

class FrontDocumentSelected extends UploadIdEvent {
  final File file;

  const FrontDocumentSelected(this.file);
}

class BackDocumentSelected extends UploadIdEvent {
  final File file;

  const BackDocumentSelected(this.file);
}

class ConfirmationChanged extends UploadIdEvent {
  final bool value;

  const ConfirmationChanged(this.value);
}

class SubmitUploadId extends UploadIdEvent {
  const SubmitUploadId();
}
