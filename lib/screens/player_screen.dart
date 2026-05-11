import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../app_theme.dart';
import '../models/media_item.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.item});

  final MediaItem item;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  AudioPlayer? _audioPlayer;
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  String? _error;

  bool get _isAudio => widget.item.mediaType == MediaType.audio;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (_isAudio) {
        final player = AudioPlayer();
        await player.setFilePath(widget.item.path);
        await player.play();
        if (!mounted) {
          await player.dispose();
          return;
        }
        setState(() {
          _audioPlayer = player;
          _isLoading = false;
        });
      } else {
        final controller = VideoPlayerController.file(File(widget.item.path));
        await controller.initialize();
        await controller.setLooping(false);
        await controller.play();
        if (!mounted) {
          await controller.dispose();
          return;
        }
        setState(() {
          _videoController = controller;
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _error = 'Unable to open media: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleVideoPlayback() async {
    final controller = _videoController;
    if (controller == null) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  Future<void> _seekVideo(Duration delta) async {
    final controller = _videoController;
    if (controller == null) {
      return;
    }

    final duration = controller.value.duration;
    final current = controller.value.position;
    final target = current + delta;
    final clamped = Duration(
      milliseconds: target.inMilliseconds.clamp(0, duration.inMilliseconds),
    );
    await controller.seekTo(clamped);
  }

  Future<void> _toggleAudioPlayback() async {
    final player = _audioPlayer;
    if (player == null) {
      return;
    }

    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> _seekAudio(Duration delta) async {
    final player = _audioPlayer;
    if (player == null) {
      return;
    }

    final current = player.position;
    final duration = player.duration ?? Duration.zero;
    final target = current + delta;
    final clamped = Duration(
      milliseconds: target.inMilliseconds.clamp(0, duration.inMilliseconds),
    );
    await player.seek(clamped);
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Media Player',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(onPressed: null, icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF0B1A33), Color(0xFF050C1A)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _isAudio
              ? _buildAudioPlayer()
              : _buildVideoPlayer(),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final controller = _videoController!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF266E90), Color(0xFF14253D)],
            ),
          ),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: VideoPlayer(controller),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          widget.item.name,
          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Recorded locally • Ready to play',
          style: TextStyle(color: Color(0xFF8FA3C2)),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: controller,
          builder: (context, VideoPlayerValue value, child) {
            final totalMs = value.duration.inMilliseconds;
            final positionMs = value.position.inMilliseconds.clamp(
              0,
              totalMs > 0 ? totalMs : 0,
            );
            return Column(
              children: <Widget>[
                Slider(
                  value: totalMs == 0 ? 0 : positionMs.toDouble(),
                  max: totalMs == 0 ? 1 : totalMs.toDouble(),
                  onChanged: (double newValue) {
                    controller.seekTo(Duration(milliseconds: newValue.round()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_format(value.position)),
                    Text(_format(value.duration)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      onPressed: () => _seekVideo(const Duration(seconds: -10)),
                      iconSize: 34,
                      icon: const Icon(Icons.replay_10_rounded),
                    ),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2666F2),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(
                              0xFF2666F2,
                            ).withValues(alpha: 0.45),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _toggleVideoPlayback,
                        iconSize: 42,
                        icon: Icon(
                          value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _seekVideo(const Duration(seconds: 10)),
                      iconSize: 34,
                      icon: const Icon(Icons.forward_10_rounded),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAudioPlayer() {
    final player = _audioPlayer!;
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder:
          (BuildContext context, AsyncSnapshot<Duration> positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final total = player.duration ?? Duration.zero;
            final maxMs = total.inMilliseconds == 0 ? 1 : total.inMilliseconds;
            final posMs = position.inMilliseconds.clamp(0, maxMs);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFF2B67F5),
                      width: 3,
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Color(0xFF0E274A), Color(0xFF040A15)],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.multitrack_audio,
                        size: 110,
                        color: AppTheme.accentSoft,
                      ),
                      Positioned(
                        bottom: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2564F3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.item.name,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Screen & Audio Extraction',
                  style: TextStyle(color: Color(0xFF8EA2C0)),
                ),
                const SizedBox(height: 10),
                Slider(
                  value: posMs.toDouble(),
                  max: maxMs.toDouble(),
                  onChanged: (double value) {
                    player.seek(Duration(milliseconds: value.round()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_format(position)),
                    Text(_format(total)),
                  ],
                ),
                const SizedBox(height: 24),
                StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<PlayerState> stateSnapshot,
                      ) {
                        final isPlaying = stateSnapshot.data?.playing ?? false;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                              onPressed: () =>
                                  _seekAudio(const Duration(seconds: -10)),
                              iconSize: 34,
                              icon: const Icon(Icons.replay_10_rounded),
                            ),
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF2666F2),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2666F2,
                                    ).withValues(alpha: 0.45),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: _toggleAudioPlayback,
                                iconSize: 42,
                                icon: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _seekAudio(const Duration(seconds: 10)),
                              iconSize: 34,
                              icon: const Icon(Icons.forward_10_rounded),
                            ),
                          ],
                        );
                      },
                ),
              ],
            );
          },
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
