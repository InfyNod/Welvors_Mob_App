import '../domain/upload_id_repository.dart';
import '../models/upload_id_model.dart';

class UploadIdRepositoryImpl implements UploadIdRepository {
  @override
  Future<bool> submitDocument(UploadIdModel model) async {
    // TODO: Replace with actual API

    await Future.delayed(const Duration(seconds: 2));

    return true;
  }
}
