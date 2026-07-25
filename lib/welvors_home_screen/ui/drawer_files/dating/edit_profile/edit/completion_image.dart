import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class CompletionAndPhotosSection extends StatefulWidget {
  const CompletionAndPhotosSection({super.key});

  @override
  State<CompletionAndPhotosSection> createState() => _CompletionAndPhotosSectionState();
}

class _CompletionAndPhotosSectionState extends State<CompletionAndPhotosSection> {
  final List<XFile?> _photos = [null, null, null, null, null, null];
  final ImagePicker _picker = ImagePicker();

  int get _photoCount => _photos.where((p) => p != null).length;

  Future<void> _pickImage() async {
    final emptyIndex = _photos.indexWhere((p) => p == null);
    if (emptyIndex != -1) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _photos[emptyIndex] = image;
        });
      }
    }
  }

  Future<void> _replaceImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos[index] = image;
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      _photos.add(null); // Shifts remaining photos left and adds empty slot at the end
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileCompletionCard(),
        const SizedBox(height: 32),
        _buildPhotosSection(),
      ],
    );
  }

  Widget _buildProfileCompletionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile completion',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '82%',
                style: TextStyle(
                  color: Color(0xFFE43A6A),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.82,
              minHeight: 8,
              backgroundColor: Color(0xFFF3F2EE),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE43A6A)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Add 1 more photo and a video to reach 100% and get 3x more matches.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
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
            return _buildPhotoSlot(index);
          },
        ),
      ],
    );
  }

  Widget _buildPhotoSlot(int index) {
    final photo = _photos[index];
    final isMain = index == 0 && photo != null;

    if (photo != null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: FileImage(File(photo.path)),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isMain)
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
            if (_photoCount > 2)
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
                  onPressed: () => _removePhoto(index),
                ),
              ),
            Positioned(
              bottom: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _replaceImage(index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
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
      onTap: () => _pickImage(),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: const [6, 4],
        color: const Color(0xFFE43A6A).withOpacity(0.4),
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
