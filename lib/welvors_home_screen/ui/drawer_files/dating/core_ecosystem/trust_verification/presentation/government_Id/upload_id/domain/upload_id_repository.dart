import '../models/upload_id_model.dart';

abstract class UploadIdRepository {
  Future<bool> submitDocument(UploadIdModel model);
}
