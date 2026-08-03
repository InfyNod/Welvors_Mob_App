import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'dart:io';

class VideoSection extends StatefulWidget {
  const VideoSection({super.key});

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  VideoPlayerController? _thumbnailController;

  @override
  void initState() {
    super.initState();
    // Initialize with existing video if it exists when the screen is loaded
    final initialVideoPath = context.read<ProfileEditCubit>().state.videoPath;
    if (initialVideoPath != null && initialVideoPath.isNotEmpty) {
      _initializeThumbnail(initialVideoPath);
    }
  }

  @override
  void dispose() {
    _thumbnailController?.dispose();
    super.dispose();
  }

  void _initializeThumbnail(String path) {
    _thumbnailController?.dispose();
    if (path.startsWith('http')) {
      _thumbnailController = VideoPlayerController.networkUrl(Uri.parse(path));
    } else if (path.startsWith('assets/')) {
      _thumbnailController = VideoPlayerController.asset(path);
    } else {
      _thumbnailController = VideoPlayerController.file(File(path));
    }
    _thumbnailController!
      ..initialize().then((_) {
        if (mounted) setState(() {});
      }).catchError((e) {
        debugPrint('Thumbnail Init Error: $e');
        if (mounted) setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditCubit, ProfileEditState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        const Row(
          children: [
            Icon(Icons.videocam_outlined, color: Color(0xFFE43A6A), size: 18),
            SizedBox(width: 8),
            Text(
              'VIDEO',
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
        state.videoPath == null
            ? _buildEmptyCard()
            : _buildRecordedCard(state.videoPath!),
        const SizedBox(height: 12),
        Text(
          'Record a 30s intro live to keep profiles genuine. A live video gets 2x more matches.',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
      );
      },
    );
  }

  Widget _buildEmptyCard() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => const VideoRecorderScreen(),
          ),
        );
        if (result != null && mounted) {
          context.read<ProfileEditCubit>().updateVideoPath(result);
          _initializeThumbnail(result);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record a live video',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Camera opens right here — no uploads',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.videocam_outlined,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordedCard(String videoPath) {
    return Container(
      width: 180,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _thumbnailController != null && _thumbnailController!.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _thumbnailController!.value.size.width,
                      height: _thumbnailController!.value.size.height,
                      child: VideoPlayer(_thumbnailController!),
                    ),
                  )
                : const Center(child: CircularProgressIndicator(color: Color(0xFFE43A6A))),
          ),
          // Dark Gradient overlay at bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // LIVE Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFFE43A6A), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          // Cross (Remove) Icon
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                context.read<ProfileEditCubit>().updateVideoPath(null);
                _thumbnailController?.dispose();
                _thumbnailController = null;
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
          // Play Button
          Center(
            child: GestureDetector(
              onTap: () {
                if (_thumbnailController != null) {
                  setState(() {
                    if (_thumbnailController!.value.isPlaying) {
                      _thumbnailController!.pause();
                    } else {
                      _thumbnailController!.play();
                    }
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  (_thumbnailController != null && _thumbnailController!.value.isPlaying)
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          // Bottom Actions
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Color(0xFFE43A6A), size: 14),
                    SizedBox(width: 6),
                    Text('Intro video added', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VideoRecorderScreen(),
                      ),
                    );
                    if (result != null && mounted) {
                      context.read<ProfileEditCubit>().updateVideoPath(result);
                      _initializeThumbnail(result);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: Text('Retake', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoRecorderScreen extends StatefulWidget {
  const VideoRecorderScreen({super.key});

  @override
  State<VideoRecorderScreen> createState() => _VideoRecorderScreenState();
}


enum RecordState { idle, recording, reviewing }

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _cameraError = false;

  RecordState _recordState = RecordState.idle;
  int _remainingSeconds = 30;
  Timer? _timer;
  String? _recordedFilePath;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _cameraError = true;
          });
        }
        return;
      }

      CameraDescription? frontCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }
      frontCamera ??= cameras.first;

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _cameraError = true;
        });
      }
    }
  }

  void _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_cameraController!.value.isRecordingVideo) return;

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _recordState = RecordState.recording;
        _remainingSeconds = 30;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _stopRecording();
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo) return;
    
    _timer?.cancel();
    
    try {
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      _recordedFilePath = videoFile.path;
      
      _videoPlayerController = VideoPlayerController.file(File(_recordedFilePath!))
        ..initialize().then((_) {
          _videoPlayerController!.setLooping(true);
          _videoPlayerController!.play();
          if (mounted) {
            setState(() {
              _recordState = RecordState.reviewing;
            });
          }
        });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _retakeVideo() {
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _recordedFilePath = null;
    setState(() {
      _recordState = RecordState.idle;
      _remainingSeconds = 30;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_recordState != RecordState.recording)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  Text(
                    _recordState == RecordState.reviewing ? 'Review your video' : 'Live intro video',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Camera Preview / Video Review
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video Player or Camera Preview
                      if (_recordState == RecordState.reviewing && _videoPlayerController != null)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoPlayerController!.value.size.width,
                            height: _videoPlayerController!.value.size.height,
                            child: VideoPlayer(_videoPlayerController!),
                          ),
                        )
                      else if (_cameraError)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 48),
                              SizedBox(height: 16),
                              Text(
                                'Camera Access Needed',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Please allow camera permissions in\nyour settings to record a video.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white54, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      else if (_isCameraInitialized && _cameraController != null)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _cameraController!.value.previewSize?.height ?? 1,
                            height: _cameraController!.value.previewSize?.width ?? 1,
                            child: CameraPreview(_cameraController!),
                          ),
                        )
                      else
                        const Center(child: CircularProgressIndicator(color: Color(0xFFE43A6A))),

                      // Recording Overlays
                      if (_recordState == RecordState.recording) ...[
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE43A6A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('REC', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  value: _remainingSeconds / 30,
                                  color: const Color(0xFFE43A6A),
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  strokeWidth: 3,
                                ),
                              ),
                              Text(
                                '0:${_remainingSeconds.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Section (Instructions / Controls)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: _recordState == RecordState.reviewing
                  ? _buildReviewControls()
                  : (_recordState == RecordState.recording
                      ? _buildRecordingControls()
                      : _buildIdleControls()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: _retakeVideo,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: const [
                Icon(Icons.replay, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Retake', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context, _recordedFilePath);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: const [
                Icon(Icons.check, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Use video', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingControls() {
    return Column(
      children: [
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54, width: 2),
            ),
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFE43A6A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Tap to stop', style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildIdleControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Before you start',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildInstructionItem('1', 'Find good light — face a window if you can.'),
        const SizedBox(height: 12),
        _buildInstructionItem('2', 'Say hi and share one thing you love.'),
        const SizedBox(height: 12),
        _buildInstructionItem('3', 'You get 30 seconds. Be yourself!'),
        const SizedBox(height: 32),
        Center(
          child: GestureDetector(
            onTap: _startRecording,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Start recording',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
