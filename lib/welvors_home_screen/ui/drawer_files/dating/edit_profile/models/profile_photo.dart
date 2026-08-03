import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhoto extends Equatable {
  final String? id;
  final String? url;
  final XFile? localFile;
  final bool isUploading;
  final String? uploadError;

  const ProfilePhoto({
    this.id,
    this.url,
    this.localFile,
    this.isUploading = false,
    this.uploadError,
  });

  bool get isNetwork => url != null;
  bool get isLocal => localFile != null;
  bool get isEmpty => !isNetwork && !isLocal;

  ProfilePhoto copyWith({
    String? id,
    String? url,
    XFile? localFile,
    bool? isUploading,
    String? uploadError,
    bool clearError = false,
  }) {
    return ProfilePhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      localFile: localFile ?? this.localFile,
      isUploading: isUploading ?? this.isUploading,
      uploadError: clearError ? null : (uploadError ?? this.uploadError),
    );
  }

  @override
  List<Object?> get props => [id, url, localFile?.path, isUploading, uploadError];
}
