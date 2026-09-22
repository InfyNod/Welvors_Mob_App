import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';

/// Bottom sheet modal presenting attachment options (Gallery, Camera, Audio, Document, Location, Contact).
class ChatAttachmentBottomSheet extends StatelessWidget {
  final String userName;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onPickAudio;
  final VoidCallback onPickDocument;
  final VoidCallback onPickLocation;
  final VoidCallback onPickContact;

  const ChatAttachmentBottomSheet({
    super.key,
    required this.userName,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onPickAudio,
    required this.onPickDocument,
    required this.onPickLocation,
    required this.onPickContact,
  });

  static void show(
    BuildContext context, {
    required String userName,
    required VoidCallback onPickGallery,
    required VoidCallback onPickCamera,
    required VoidCallback onPickAudio,
    required VoidCallback onPickDocument,
    required VoidCallback onPickLocation,
    required VoidCallback onPickContact,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => ChatAttachmentBottomSheet(
        userName: userName,
        onPickGallery: () {
          Navigator.pop(sheetContext);
          onPickGallery();
        },
        onPickCamera: () {
          Navigator.pop(sheetContext);
          onPickCamera();
        },
        onPickAudio: () {
          Navigator.pop(sheetContext);
          onPickAudio();
        },
        onPickDocument: () {
          Navigator.pop(sheetContext);
          onPickDocument();
        },
        onPickLocation: () {
          Navigator.pop(sheetContext);
          onPickLocation();
        },
        onPickContact: () {
          Navigator.pop(sheetContext);
          onPickContact();
        },
      ),
    );
  }

  Widget _shareOption({
    required IconData icon,
    required String iconPath,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: iconPath.isEmpty
                ? Icon(icon, color: Colors.white, size: 24)
                : Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        iconPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.sub.copyWith(color: AppColors.ink60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text('Share with $userName', style: AppText.h2),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 2,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
                children: [
                  _shareOption(
                    icon: Icons.photo_outlined,
                    iconPath: 'assets/gallery.jpeg',
                    label: 'Gallery',
                    color: const Color(0xFF7C6CF0),
                    onTap: onPickGallery,
                  ),
                  _shareOption(
                    icon: Icons.camera_alt_outlined,
                    iconPath: 'assets/camera.jpg',
                    label: 'Camera',
                    color: Colors.transparent,
                    onTap: onPickCamera,
                  ),
                  _shareOption(
                    icon: Icons.music_note_outlined,
                    iconPath: 'assets/audio.jpg',
                    label: 'Audio',
                    color: const Color(0xFFE8A53D),
                    onTap: onPickAudio,
                  ),
                  _shareOption(
                    icon: Icons.insert_drive_file_outlined,
                    iconPath: 'assets/document.jpg',
                    label: 'Document',
                    color: const Color(0xFF3D8BE8),
                    onTap: onPickDocument,
                  ),
                  _shareOption(
                    icon: Icons.location_on_outlined,
                    iconPath: 'assets/location.jpg',
                    label: 'Location',
                    color: const Color(0xFF2EAF6B),
                    onTap: onPickLocation,
                  ),
                  _shareOption(
                    icon: Icons.person_outline,
                    iconPath: 'assets/contact.jpg',
                    label: 'Contact',
                    color: const Color(0xFF8A8680),
                    onTap: onPickContact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
