import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';
import 'user_data.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class PhotosScreen extends StatefulWidget {
  final VoidCallback onNext;
  const PhotosScreen({super.key, required this.onNext});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> with AutomaticKeepAliveClientMixin  {
  final List<dynamic> _photos = [null, null, null, null, null, null];
  final ImagePicker _picker = ImagePicker();

  int get _photoCount => _photos.where((p) => p != null && p is! Color).length;
  bool get _isFormValid => _photoCount >= 2;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ApiService.fetchOnboardingDetails('PHOTOS');
    if (data != null && data is List && mounted) {
      setState(() {
        for (var item in data) {
          if (item['mediaUrl'] != null && item['order'] != null) {
            int order = item['order'] - 1; // Assuming order starts from 1
            if (order >= 0 && order < 6) {
              _photos[order] = item['mediaUrl'];
            }
          }
        }
      });
    }
  }

  void _handleAddPhoto() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Add Photo'),
        message: const Text('Choose a photo for your profile'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Choose from Gallery'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Take a Photo'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final emptyIndex = _photos.indexWhere((p) => p == null);
    if (emptyIndex != -1) {
      try {
        final XFile? image = await _picker.pickImage(
          source: source,
          imageQuality: 60, // Compress image quality to 60%
          maxWidth: 1080,   // Max width for upload optimization
          maxHeight: 1080,  // Max height for upload optimization
        );
        if (image != null) {
          setState(() {
            _photos[emptyIndex] = image;
          });
        }
      } catch (e) {
        AppLogger.e('PhotosScreen', 'Error picking image: $e');
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      _photos.add(null);
    });
  }

  Widget _buildPhotoSlot(int index) {
    final photo = _photos[index];
    final isMain = index == 0 && photo != null;

    if (photo != null) {
      // Filled slot
      ImageProvider? imgProvider;
      if (photo is XFile) {
        imgProvider = FileImage(File(photo.path));
      } else if (photo is String) {
        imgProvider = NetworkImage(photo);
      }

      return Container(
        decoration: BoxDecoration(
          color: photo is Color ? photo : AppColors.line,
          borderRadius: BorderRadius.circular(12),
          image: imgProvider != null
              ? DecorationImage(
                  image: imgProvider,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            if (isMain)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Main',
                    style: AppText.body.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _removePhoto(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty slot
    return GestureDetector(
      onTap: _handleAddPhoto,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: const [6, 4],
        color: AppColors.pinkDeep.withValues(alpha: 0.4),
        strokeWidth: 1.5,
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              if (index == 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Main',
                      style: AppText.body.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pinkDeep.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.pinkDeep,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR PROFILE',
                  style: AppText.eyebrow.copyWith(
                    color: AppColors.pinkDeep,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a few photos.',
                  style: AppText.display.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'Profiles with three or more clear photos get\nnoticed more. Add up to six — your first one\nis your main.',
                  style: AppText.sub.copyWith(
                    color: AppColors.ink60,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // Grid of photos
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return _buildPhotoSlot(index);
                  },
                ),

                const SizedBox(height: 24),

                // Status indicator
                Row(
                  children: [
                    Icon(
                      _isFormValid ? Icons.check : Icons.circle_outlined,
                      color: _isFormValid ? Colors.green : AppColors.muted,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_photoCount of 6 added · ',
                      style: AppText.body.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      _isFormValid ? 'minimum met' : 'need at least 2',
                      style: AppText.body.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pad,
            8,
            AppDimens.pad,
            20,
          ),
          child: PrimaryButton(
            _isSubmitting ? 'Uploading...' : 'Continue',
            onTap: (_isFormValid && !_isSubmitting)
                ? () async {
                    setState(() => _isSubmitting = true);

                    final validPhotos = _photos.whereType<XFile>().toList();
                    final paths = validPhotos.map((f) => f.path).toList();

                    String? errorMsg;
                    if (paths.isNotEmpty) {
                      errorMsg = await ApiService.submitPhotos(paths);
                    }

                    if (mounted) {
                      setState(() => _isSubmitting = false);

                      if (errorMsg != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      } else {
                        // Local backup
                        userData.photoCount = _photoCount;
                        final allValid = _photos.where((p) => p != null).toList();
                        userData.photos = allValid.map((p) {
                          if (p is XFile) return File(p.path);
                          return p; // keep string URL
                        }).toList();

                        widget.onNext();
                      }
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
