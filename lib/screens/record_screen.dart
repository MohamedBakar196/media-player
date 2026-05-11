import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/media_item.dart';
import '../services/media_library_service.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({
    super.key,
    required this.active,
    required this.onFileReady,
  });

  final bool active;

  final ValueChanged<MediaItem> onFileReady;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  CameraController? _cameraController;
  bool _isLoading = true;
  bool _isRecording = false;
  String? _error;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isSwitchingState = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      _initializeCamera();
    } else {
      _isLoading = false;
    }
  }

  @override
  void didUpdateWidget(covariant RecordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active == widget.active) {
      return;
    }

    if (widget.active) {
      _initializeCamera();
    } else {
      unawaited(_releaseCamera());
    }
  }

  Future<void> _initializeCamera() async {
    if (_isSwitchingState) {
      return;
    }

    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = 'No camera found on this device.';
          _isLoading = false;
        });
        return;
      }

      final selected = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: true,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Camera initialization failed: $error';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _releaseCamera() async {
    if (_isSwitchingState) {
      return;
    }

    _isSwitchingState = true;
    try {
      final controller = _cameraController;
      if (controller == null) {
        return;
      }

      if (controller.value.isRecordingVideo) {
        final xFile = await controller.stopVideoRecording();
        _timer?.cancel();
        _timer = null;
        _elapsed = Duration.zero;
        _isRecording = false;

        final item = await MediaLibraryService.instance.addFile(
          File(xFile.path),
          preferredName: 'capture_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (mounted) {
          widget.onFileReady(item);
        }
      }

      await controller.dispose();
      if (mounted) {
        setState(() {
          _cameraController = null;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Camera shutdown failed: $error';
          _isLoading = false;
        });
      }
    } finally {
      _isSwitchingState = false;
    }
  }

  Future<void> _toggleRecording() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      if (_isRecording) {
        final xFile = await controller.stopVideoRecording();
        _timer?.cancel();
        setState(() {
          _isRecording = false;
        });

        final item = await MediaLibraryService.instance.addFile(
          File(xFile.path),
          preferredName: 'capture_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (!mounted) {
          return;
        }
        widget.onFileReady(item);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Video saved to library')));
      } else {
        await controller.startVideoRecording();
        setState(() {
          _isRecording = true;
          _elapsed = Duration.zero;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
          if (!mounted || !_isRecording) {
            timer.cancel();
            return;
          }
          setState(() {
            _elapsed += const Duration(seconds: 1);
          });
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Recording failed: $error')));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!widget.active) {
      return const Center(
        child: Text('Camera is paused while you browse other tabs.'),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: Text('Camera unavailable.'));
    }

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CameraPreview(controller),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.fiber_manual_record,
                    color: _isRecording ? Colors.red : Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isRecording
                        ? 'REC  ${_format(_elapsed)}'
                        : 'Ready to record',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: const Color(0xFF1A283B),
                    ),
                    child: const Row(
                      children: <Widget>[
                        Icon(
                          Icons.battery_5_bar_rounded,
                          color: Color(0xFF9FF2B5),
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text('84%'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 166,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'ACTIVE STREAM',
                        style: TextStyle(
                          color: Color(0xFF2DAAFF),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '1080p | 60fps | HEVC',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _RoundButton(
                  icon: Icons.pause,
                  onTap: _isRecording ? _toggleRecording : null,
                ),
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red : AppTheme.accent,
                      border: Border.all(color: Colors.white, width: 6),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: (_isRecording ? Colors.red : AppTheme.accent)
                              .withValues(alpha: 0.45),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.videocam,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                ),
                _RoundButton(icon: Icons.photo_camera_outlined, onTap: null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Ink(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.35),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
