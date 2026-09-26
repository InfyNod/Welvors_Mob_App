import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import '../models/profile_photo.dart';

class CompletionAndPhotosSection extends StatelessWidget {
  CompletionAndPhotosSection({super.key});

  final ImagePicker _picker = ImagePicker();

  int _photoCount(List<ProfilePhoto?> photos) => photos.where((p) => p != null && !p.isEmpty).length;

  Future<void> _pickImage(BuildContext context, List<ProfilePhoto?> currentPhotos) async {
    final emptyIndex = currentPhotos.indexWhere((p) => p == null || p.isEmpty);
    if (emptyIndex != -1) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      if (image != null && context.mounted) {
        context.read<ProfileEditCubit>().updateSinglePhoto(emptyIndex, image);
      }
    }
  }

  Future<void> _replaceImage(BuildContext context, int index) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (image != null && context.mounted) {
      context.read<ProfileEditCubit>().updateSinglePhoto(index, image);
    }
  }

  void _removePhoto(BuildContext context, List<ProfilePhoto?> currentPhotos, int index) {
    context.read<ProfileEditCubit>().removePhoto(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditCubit, ProfileEditState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCompletionCard(state),
            const SizedBox(height: 32),
            _buildPhotosSection(context, state.photos),
          ],
        );
      },
    );
  }

  Widget _buildProfileCompletionCard(ProfileEditState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE43A6A).withValues(alpha: 0.08)), // Subtle pink border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: state.completionPercentage),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile completion',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14, // Slightly smaller
                      fontWeight: FontWeight.w800, // Extra bold for premium look
                    ),
                  ),
                  Text(
                    '${(animValue * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFFE43A6A),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Reduced spacing
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F2EE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Animated Gradient Progress Bar
                  FractionallySizedBox(
                    widthFactor: animValue,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFA7B9), // Light pink
                            Color(0xFFE43A6A), // Dark premium pink
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Reduced spacing
              Text(
                'Add 1 more photo and a video to reach 100% and get 3x more matches.',
                style: TextStyle(
                  color: Colors.grey.shade600, // Softer grey
                  fontSize: 11, // Smaller text
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhotosSection(BuildContext context, List<ProfilePhoto?> photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.photo_library_outlined, color: Color(0xFFE43A6A), size: 16),
            SizedBox(width: 8),
            Text(
              'PHOTOS',
              style: TextStyle(
                color: Color(0xFFE43A6A),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8, // Matches onboarding
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return _buildPhotoSlot(context, photos, index);
          },
        ),
      ],
    );
  }

  Widget _buildPhotoSlot(BuildContext context, List<ProfilePhoto?> photos, int index) {
    final photo = photos[index];
    final isMain = index == 0 && photo != null && !photo.isEmpty;

    if (photo != null && !photo.isEmpty) {
      ImageProvider? imageProvider;
      if (photo.isNetwork) {
        imageProvider = NetworkImage(photo.url!);
      } else if (photo.isLocal) {
        imageProvider = FileImage(File(photo.localFile!.path));
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          image: imageProvider != null
              ? DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (photo.isUploading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
              ),
            if (photo.uploadError != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 24),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          photo.uploadError ?? 'Failed',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (isMain && !photo.isUploading && photo.uploadError == null)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE43A6A), // Pink main badge
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Main',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (_photoCount(photos) > 2 && !photo.isUploading)
              Positioned(
                top: -6,
                right: -6,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 12),
                  ),
                  onPressed: () => _removePhoto(context, photos, index),
                ),
              ),
            if (!photo.isUploading)
              Positioned(
                bottom: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => _replaceImage(context, index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit, color: Color(0xFFE43A6A), size: 14),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Empty slot
    return GestureDetector(
      onTap: () => _pickImage(context, photos),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: const [6, 4],
        color: const Color(0xFFE43A6A).withValues(alpha: 0.4),
        strokeWidth: 1.5,
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFFE43A6A),
                size: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
