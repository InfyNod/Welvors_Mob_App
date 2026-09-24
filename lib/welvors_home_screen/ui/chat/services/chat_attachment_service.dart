import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/config/env_config.dart';
import '../ChatVideoPlayer.dart';
import '../chat_bloc/chat_bloc.dart';
import '../chat_bloc/chat_event.dart';
import '../chat_bloc/chat_state.dart';
import '../custom_camera_screen.dart' as custom_camera;
import '../location_map_screen.dart';
import '../widgets/sheets/chat_contact_picker_sheet.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

/// Helper service responsible for picking, compressing, uploading, and dispatching
/// media attachments (images, audio, documents, videos, locations, contacts).
class ChatAttachmentService {
  final BuildContext Function() getContext;
  final ChatUser user;
  final ChatMessage? Function() getReplyingTo;
  final VoidCallback onClearReply;
  final VoidCallback onScrollToBottom;
  final void Function(String message) showToast;
  final VoidCallback onShowLoader;
  final VoidCallback onHideLoader;

  ChatAttachmentService({
    required this.getContext,
    required this.user,
    required this.getReplyingTo,
    required this.onClearReply,
    required this.onScrollToBottom,
    required this.showToast,
    required this.onShowLoader,
    required this.onHideLoader,
  });

  BuildContext get context => getContext();

  Future<void> pickGallery() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      onShowLoader();
      try {
        for (final picked in result.files) {
          final path = picked.path;
          if (path == null || path.isEmpty) continue;

          final extension = path.split('.').last.toLowerCase();
          final xFile = XFile(path);

          if ({
            'jpg',
            'jpeg',
            'png',
            'webp',
            'heic',
            'heif',
          }.contains(extension)) {
            await uploadAndSendImage(xFile);
          } else if ({
            'mp4',
            'mov',
            'm4v',
            'avi',
            'mkv',
            'webm',
            '3gp',
          }.contains(extension)) {
            await uploadAndSendVideo(
              xFile,
              fileName: picked.name,
              fileSize: picked.size,
            );
          } else {
            AppLogger.w('ChatAttachmentService', '⚠️ Unsupported gallery media: ${picked.name}');
          }
        }
      } finally {
        onHideLoader();
      }
    } catch (e, st) {
      AppLogger.e('ChatAttachmentService', '❌ GALLERY IMAGE ERROR: $e');
      AppLogger.d('ChatAttachmentService', '$st');
      showToast('Unable to send image');
    }
  }

  Future<File?> compressChatImage(XFile image) async {
    try {
      final originalBytes = await image.readAsBytes();
      AppLogger.d('ChatAttachmentService', 
        '🖼️ ORIGINAL IMAGE SIZE => '
        '${(originalBytes.length / 1024).toStringAsFixed(2)} KB',
      );

      final jpgBytes = await compute(encodeChatImageIsolate, originalBytes);

      if (jpgBytes == null) {
        AppLogger.e('ChatAttachmentService', '❌ IMAGE DECODE/ENCODE FAILED');
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/chat_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(jpgBytes, flush: true);

      AppLogger.i('ChatAttachmentService', 
        '✅ COMPRESSED IMAGE SIZE => '
        '${(jpgBytes.length / 1024).toStringAsFixed(2)} KB',
      );

      return file;
    } catch (e, st) {
      AppLogger.e('ChatAttachmentService', '❌ IMAGE COMPRESSION ERROR => $e');
      AppLogger.d('ChatAttachmentService', '$st');
      return null;
    }
  }

  Future<void> uploadAndSendImage(XFile image) async {
    final conversationId = user.conversationId;

    if (conversationId == null || conversationId.isEmpty) {
      AppLogger.e('ChatAttachmentService', '❌ IMAGE: conversationId missing');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      AppLogger.d('ChatAttachmentService', '==========================================');
      AppLogger.d('ChatAttachmentService', '📤 IMAGE UPLOAD START');
      AppLogger.d('ChatAttachmentService', '📤 ORIGINAL FILE => ${image.path}');

      final compressedFile = await compressChatImage(image);

      if (compressedFile == null) {
        throw Exception('Unable to compress image');
      }

      final compressedSize = await compressedFile.length();
      AppLogger.d('ChatAttachmentService', '📤 COMPRESSED FILE => ${compressedFile.path}');
      AppLogger.d('ChatAttachmentService', '📤 COMPRESSED SIZE => ${(compressedSize / 1024).toStringAsFixed(2)} KB');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${EnvConfig.apiBaseUrl}/chat/message/upload_image'),
      );

      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] =
            token.toLowerCase().startsWith('bearer ') ? token : 'Bearer $token';
      }

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        compressedFile.path,
        filename: 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      request.files.add(multipartFile);

      AppLogger.d('ChatAttachmentService', '📤 REQUEST URL => ${request.url}');
      AppLogger.d('ChatAttachmentService', '📤 REQUEST HEADERS => ${request.headers}');
      AppLogger.d('ChatAttachmentService', '📤 SENDING REQUEST...');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.d('ChatAttachmentService', '📤 RESPONSE STATUS => ${response.statusCode}');
      AppLogger.d('ChatAttachmentService', '📤 RESPONSE BODY => ${response.body}');

      if (response.statusCode == 413) {
        throw Exception('Image size is too large for server');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Upload failed with status ${response.statusCode}');
      }

      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (decoded['status'] != true) {
        throw Exception(decoded['message'] ?? 'Image upload failed');
      }

      final data = decoded['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Invalid image data returned');
      }

      final imageUrl = data['image_url']?.toString().trim();

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Image URL not found in response');
      }

      AppLogger.i('ChatAttachmentService', '✅ FINAL IMAGE URL => $imageUrl');

      final reply = getReplyingTo();

      context.read<ChatBloc>().add(
        SendMessageEvent(
          chatId: user.id,
          conversationId: user.conversationId,
          type: ChatMessageType.image,
          imageUrl: imageUrl,
          typemsg: 'Image',
          replyToId: reply?.id,
          replyText: reply?.text,
          replyImageUrl: reply?.imageUrl,
          replyFileUrl: reply?.fileUrl,
          replyType: reply?.type,
        ),
      );

      onClearReply();
      onScrollToBottom();
      AppLogger.i('ChatAttachmentService', '🎉 IMAGE MESSAGE SENT SUCCESSFULLY');
    } catch (e, st) {
      AppLogger.e('ChatAttachmentService', '❌ IMAGE UPLOAD ERROR => $e');
      AppLogger.d('ChatAttachmentService', '$st');
      showToast('Image sending failed');
    }
  }

  Future<void> openCamera() async {
    await captureImage();
  }

  Future<void> captureImage() async {
    try {
      AppLogger.d('ChatAttachmentService', '📷 CAPTURE IMAGE START');

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        preferredCameraDevice: CameraDevice.rear,
      );

      XFile? finalFile = picked;

      if (finalFile == null) {
        AppLogger.w('ChatAttachmentService', '⚠️ ImagePicker returned null, opening CustomCameraScreen');

        final customResult = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (_) => const custom_camera.CustomCameraScreen(),
          ),
        );

        if (customResult != null && customResult.isNotEmpty) {
          finalFile = XFile(customResult);
        }
      }

      if (finalFile == null) {
        AppLogger.d('ChatAttachmentService', 'ℹ️ Camera capture cancelled by user');
        return;
      }

      AppLogger.d('ChatAttachmentService', '📷 CAMERA PHOTO CAPTURED => ${finalFile.path}');

      onShowLoader();
      try {
        await uploadAndSendImage(finalFile);
      } finally {
        onHideLoader();
      }
    } catch (e, st) {
      AppLogger.e('ChatAttachmentService', '❌ CAMERA CAPTURE ERROR => $e');
      AppLogger.d('ChatAttachmentService', '$st');
      showToast('Unable to capture or send photo');
    }
  }

  Future<void> pickAudio() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.audio);

      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null || path.isEmpty) return;

      final file = File(path);
      final size = await file.length();
      final name = result.files.single.name;

      await uploadAndSendFile(
        file: file,
        fileName: name,
        fileSize: formatFileSize(size),
        type: ChatMessageType.audio,
      );
    } catch (e) {
      AppLogger.e('ChatAttachmentService', '❌ PICK AUDIO ERROR => $e');
      showToast('Unable to pick audio file');
    }
  }

  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null || path.isEmpty) return;

      final file = File(path);
      final size = await file.length();
      final name = result.files.single.name;

      await uploadAndSendFile(
        file: file,
        fileName: name,
        fileSize: formatFileSize(size),
        type: ChatMessageType.document,
      );
    } catch (e) {
      AppLogger.e('ChatAttachmentService', '❌ PICK DOCUMENT ERROR => $e');
      showToast('Unable to pick document');
    }
  }

  Future<void> uploadAndSendFile({
    required File file,
    required String fileName,
    required String fileSize,
    required ChatMessageType type,
  }) async {
    final conversationId = user.conversationId;

    if (conversationId == null || conversationId.isEmpty) {
      AppLogger.e('ChatAttachmentService', '❌ UPLOAD FILE: conversationId missing');
      return;
    }

    try {
      onShowLoader();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${EnvConfig.apiBaseUrl}/chat/message/upload_file'),
      );

      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] =
            token.toLowerCase().startsWith('bearer ') ? token : 'Bearer $token';
      }

      request.fields['conversation_id'] = conversationId;
      request.fields['file_type'] = attachmentContentType(fileName);

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path, filename: fileName),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.d('ChatAttachmentService', 'FILE UPLOAD RESPONSE: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Upload failed with status ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded['status'] != true) {
        throw Exception(decoded['message'] ?? 'File upload failed');
      }

      final fileUrl = decoded['data']['file_url'] ?? decoded['data']['url'];

      if (fileUrl == null || fileUrl.toString().trim().isEmpty) {
        throw Exception('File URL missing in response');
      }

      sendAttachment(
        type: type,
        filePath: fileUrl.toString().trim(),
        fileName: fileName,
        fileSize: fileSize,
      );
    } catch (e) {
      AppLogger.e('ChatAttachmentService', '❌ UPLOAD FILE ERROR => $e');
      showToast('Failed to upload file');
    } finally {
      onHideLoader();
    }
  }

  Future<void> uploadAndSendVideo(
    XFile video, {
    required String fileName,
    required int fileSize,
  }) async {
    final conversationId = user.conversationId;

    if (conversationId == null || conversationId.isEmpty) {
      AppLogger.e('ChatAttachmentService', '❌ VIDEO: conversationId missing');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      AppLogger.d('ChatAttachmentService', '==========================================');
      AppLogger.d('ChatAttachmentService', '🎬 VIDEO UPLOAD START');
      AppLogger.d('ChatAttachmentService', '🎬 ORIGINAL FILE => ${video.path}');
      AppLogger.d('ChatAttachmentService', '🎬 FILE SIZE => ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${EnvConfig.apiBaseUrl}/chat/message/upload_video'),
      );

      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] =
            token.toLowerCase().startsWith('bearer ') ? token : 'Bearer $token';
      }

      request.fields['conversation_id'] = conversationId;
      request.fields['file_type'] = videoContentType(fileName);

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        video.path,
        filename: fileName,
      );

      request.files.add(multipartFile);

      AppLogger.d('ChatAttachmentService', '🎬 REQUEST URL => ${request.url}');
      AppLogger.d('ChatAttachmentService', '🎬 REQUEST HEADERS => ${request.headers}');
      AppLogger.d('ChatAttachmentService', '🎬 SENDING VIDEO UPLOAD REQUEST...');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.d('ChatAttachmentService', '🎬 RESPONSE STATUS => ${response.statusCode}');
      AppLogger.d('ChatAttachmentService', '🎬 RESPONSE BODY => ${response.body}');

      if (response.statusCode == 413) {
        throw Exception('Video size is too large for server');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Upload failed with status ${response.statusCode}');
      }

      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (decoded['status'] != true) {
        throw Exception(decoded['message'] ?? 'Video upload failed');
      }

      final data = decoded['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Invalid video data returned');
      }

      final videoUrl = (data['video_url'] ?? data['file_url'] ?? data['url'])
          ?.toString()
          .trim();

      if (videoUrl == null || videoUrl.isEmpty) {
        throw Exception('Video URL not found in response');
      }

      AppLogger.i('ChatAttachmentService', '✅ FINAL VIDEO URL => $videoUrl');

      final reply = getReplyingTo();

      context.read<ChatBloc>().add(
        SendMessageEvent(
          chatId: user.id,
          conversationId: user.conversationId,
          type: ChatMessageType.video,
          fileUrl: videoUrl,
          fileName: fileName,
          fileSize: formatFileSize(fileSize),
          typemsg: 'Video',
          replyToId: reply?.id,
          replyText: reply?.text,
          replyImageUrl: reply?.imageUrl,
          replyFileUrl: reply?.fileUrl,
          replyType: reply?.type,
        ),
      );

      onClearReply();
      onScrollToBottom();
      AppLogger.i('ChatAttachmentService', '🎉 VIDEO MESSAGE SENT SUCCESSFULLY');
    } catch (e, st) {
      AppLogger.e('ChatAttachmentService', '❌ VIDEO UPLOAD ERROR => $e');
      AppLogger.d('ChatAttachmentService', '$st');
      showToast('Video sending failed');
    }
  }

  Future<void> sendLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        showToast('Location permission denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final selected = await LocationMapScreen.pick(
        context: context,
        latitude: position.latitude,
        longitude: position.longitude,
        label: 'Current Location',
      );

      if (selected == null) return;

      AppLogger.d('ChatAttachmentService', '📍 SELECTED LOCATION');
      AppLogger.d('ChatAttachmentService', 'Latitude  : ${selected.latitude}');
      AppLogger.d('ChatAttachmentService', 'Longitude : ${selected.longitude}');
      AppLogger.d('ChatAttachmentService', 'Label     : ${selected.label}');
      AppLogger.d('ChatAttachmentService', 'Address   : ${selected.address}');

      sendAttachment(
        type: ChatMessageType.location,
        text: selected.address.isNotEmpty ? selected.address : selected.label,
        latitude: selected.latitude,
        longitude: selected.longitude,
        locationLabel: selected.address.isNotEmpty
            ? selected.address
            : selected.label,
      );

      showToast('Location sent ✓');
    } catch (e, st) {
      AppLogger.e('ChatAttachmentService', '❌ LOCATION PICKER ERROR => $e');
      AppLogger.d('ChatAttachmentService', '$st');
      showToast('Unable to get location');
    }
  }

  Future<void> pickContact() async {
    try {
      final permission = await FlutterContacts.permissions.request(
        PermissionType.read,
      );

      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.limited) {
        showToast('Contact permission denied');
        return;
      }

      final contacts = await FlutterContacts.getAll(
        properties: const {ContactProperty.phone},
      );

      if (contacts.isEmpty) {
        showToast('No contacts found');
        return;
      }

      final selected = await ChatContactPickerSheet.show(context, contacts);

      if (selected == null) return;

      final phone = selected.phones.isNotEmpty
          ? selected.phones.first.number
          : '';

      sendAttachment(
        type: ChatMessageType.contact,
        text: selected.displayName ?? '',
        fileName: phone,
      );

      showToast('Contact sent ✓');
    } catch (e, stackTrace) {
      AppLogger.e('ChatAttachmentService', 'CONTACT ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      showToast('Unable to select contact');
    }
  }

  void sendAttachment({
    required ChatMessageType type,
    String text = '',
    String? filePath,
    String? fileName,
    String? fileSize,
    String? imageUrl,
    String? audioUrl,
    String? locationLabel,
    double? latitude,
    double? longitude,
  }) {
    final reply = getReplyingTo();
    final bool isContact = type == ChatMessageType.contact;
    final bool isLocation = type == ChatMessageType.location;

    final String? contactName = isContact ? text.trim() : null;
    final String? contactPhoneNumber =
        isContact ? (fileName ?? '').trim() : null;

    AppLogger.d('ChatAttachmentService', '================ SEND ATTACHMENT ================');
    AppLogger.d('ChatAttachmentService', 'chatId              : ${user.id}');
    AppLogger.d('ChatAttachmentService', 'conversationId      : ${user.conversationId}');
    AppLogger.d('ChatAttachmentService', 'type                : $type');

    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: user.id,
        conversationId: user.conversationId,
        type: type,
        contactName: contactName,
        contactPhoneNumber: contactPhoneNumber,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        fileUrl: filePath,
        fileSize: fileSize,
        locationLabel: locationLabel,
        latitude: latitude,
        longitude: longitude,
        typemsg: isContact
            ? 'CONTACT'
            : isLocation
            ? 'LOCATION'
            : 'Attachment',
        message: isLocation ? (locationLabel ?? text) : text,
        replyToId: reply?.id,
        replyText: reply?.text,
        replyImageUrl: reply?.imageUrl,
        replyFileUrl: reply?.fileUrl,
        replyType: reply?.type,
      ),
    );

    onClearReply();
    onScrollToBottom();
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String attachmentContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
        return 'audio/mp4';
      case 'wav':
        return 'audio/wav';
      case 'aac':
        return 'audio/aac';
      case 'ogg':
        return 'audio/ogg';
      default:
        return 'application/octet-stream';
    }
  }

  String videoContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'm4v':
        return 'video/x-m4v';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'webm':
        return 'video/webm';
      case '3gp':
        return 'video/3gpp';
      default:
        return 'video/mp4';
    }
  }
}
