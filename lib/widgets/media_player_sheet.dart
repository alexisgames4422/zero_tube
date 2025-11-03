import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../models/media_item.dart';
import '../theme/app_theme.dart';

class MediaPlayerSheet extends StatefulWidget {
  const MediaPlayerSheet({super.key, required this.item});

  final MediaItem item;

  @override
  State<MediaPlayerSheet> createState() => _MediaPlayerSheetState();
}

class _MediaPlayerSheetState extends State<MediaPlayerSheet> {
  AudioPlayer? _audioPlayer;
  VideoPlayerController? _videoController;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _loading = true;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer?.dispose();
    _videoController?..removeListener(_handleVideoTick);
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.item.isVideo) {
        final controller = VideoPlayerController.file(widget.item.file);
        await controller.initialize();
        controller.setLooping(false);
        controller.addListener(_handleVideoTick);

        if (!mounted) return;
        setState(() {
          _videoController = controller;
          _duration = controller.value.duration;
          _isPlaying = false;
          _loading = false;
        });

        await controller.play();
        if (!mounted) return;
        setState(() => _isPlaying = controller.value.isPlaying);
      } else {
        final player = AudioPlayer();
        await player.setFilePath(widget.item.file.path);
        _duration = player.duration ?? Duration.zero;
        player.play();
        _positionSubscription = player.positionStream.listen((position) {
          if (!mounted) return;
          setState(() => _position = position);
        });
        _playerStateSubscription = player.playerStateStream.listen((state) {
          if (!mounted) return;
          setState(() => _isPlaying = state.playing);
        });
        if (!mounted) return;
        setState(() {
          _audioPlayer = player;
          _loading = false;
          _isPlaying = true;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar la reproducción: $error')),
      );
    }
  }

  void _handleVideoTick() {
    final controller = _videoController;
    if (controller == null || !mounted) return;
    final value = controller.value;
    setState(() {
      _position = value.position;
      _duration = value.duration;
      _isPlaying = value.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHandle(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildPreview(),
                        const SizedBox(height: 20),
                        Text(
                          widget.item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.item.isVideo ? 'Video' : 'Audio',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        _buildProgressBar(),
                        const SizedBox(height: 12),
                        _buildTimeRow(),
                        const SizedBox(height: 24),
                        _buildControls(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slide(begin: const Offset(0, 0.06));
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 48,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_loading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.item.isVideo) {
      final controller = _videoController;
      if (controller == null || !controller.value.isInitialized) {
        return _buildPlaceholderIcon();
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(controller),
              if (!_isPlaying)
                Positioned.fill(
                  child: Center(
                    child: IconButton(
                      iconSize: 64,
                      icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white70),
                      onPressed: _togglePlay,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final thumbnail = widget.item.thumbnail;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.mint, AppColors.ice],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: thumbnail != null && thumbnail.existsSync()
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(thumbnail, fit: BoxFit.cover),
            )
          : _buildPlaceholderIcon(),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(Icons.graphic_eq_rounded, size: 72, color: AppColors.background),
    );
  }

  Widget _buildProgressBar() {
    final durationMs = _duration.inMilliseconds;
    final positionMs = _position.inMilliseconds.clamp(0, durationMs == 0 ? 1 : durationMs).toDouble();

    return SliderTheme(
      data: SliderThemeData(
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: AppColors.mint,
        inactiveTrackColor: AppColors.surfaceVariant,
        thumbColor: AppColors.ice,
      ),
      child: Slider(
        value: durationMs == 0 ? 0 : positionMs,
        min: 0,
        max: durationMs == 0 ? 1 : durationMs.toDouble(),
        onChanged: durationMs == 0 ? null : (value) => _seekTo(Duration(milliseconds: value.round())),
      ),
    );
  }

  Widget _buildTimeRow() {
    final duration = _formatDuration(_duration);
    final position = _formatDuration(_position);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(position, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text(duration, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 36,
          onPressed: () => _seekRelative(const Duration(seconds: -10)),
          icon: const Icon(Icons.replay_10_rounded),
        ),
        const SizedBox(width: 16),
        FloatingActionButton.large(
          heroTag: 'play-btn',
          onPressed: _togglePlay,
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.background,
          child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 42),
        ),
        const SizedBox(width: 16),
        IconButton(
          iconSize: 36,
          onPressed: () => _seekRelative(const Duration(seconds: 10)),
          icon: const Icon(Icons.forward_10_rounded),
        ),
      ],
    );
  }

  Future<void> _togglePlay() async {
    if (_loading) return;

    if (widget.item.isVideo) {
      final controller = _videoController;
      if (controller == null) return;
      if (controller.value.isPlaying) {
        await controller.pause();
      } else {
        await controller.play();
      }
      setState(() => _isPlaying = controller.value.isPlaying);
      return;
    }

    final player = _audioPlayer;
    if (player == null) return;
    if (_isPlaying) {
      await player.pause();
    } else {
      await player.play();
    }
    setState(() => _isPlaying = player.playing);
  }

  Future<void> _seekRelative(Duration offset) async {
    final target = _position + offset;
    await _seekTo(target < Duration.zero ? Duration.zero : target);
  }

  Future<void> _seekTo(Duration target) async {
    if (widget.item.isVideo) {
      final controller = _videoController;
      if (controller != null) {
        await controller.seekTo(target);
      }
    } else {
      final player = _audioPlayer;
      if (player != null) {
        await player.seek(target);
      }
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMilliseconds <= 0 || duration.isNegative) {
      return '--:--';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}
