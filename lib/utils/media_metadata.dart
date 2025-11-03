import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/media_item.dart';

class MediaMetadataResolver {
  static final _audioExtensions = {'.mp3', '.m4a', '.wav', '.aac', '.flac'};
  static final _videoExtensions = {'.mp4', '.mkv', '.webm', '.mov'};

  static bool isAudio(File file) => _hasExtension(file, _audioExtensions);

  static bool isVideo(File file) => _hasExtension(file, _videoExtensions);

  static Future<MediaItem> resolve(File file, Directory thumbnailDirectory) async {
    final isVideoFile = isVideo(file);
    final isAudioFile = MediaMetadataResolver.isAudio(file);

    Duration? duration;
    File? thumbnail;

    if (isAudioFile) {
      duration = await _resolveAudioDuration(file);
    }

    if (isVideoFile) {
      final data = await _resolveVideoMetadata(file, thumbnailDirectory);
      duration = data.$1 ?? duration;
      thumbnail = data.$2 ?? thumbnail;
    }

    return MediaItem(
      file: file,
      title: p.basenameWithoutExtension(file.path),
      isVideo: isVideoFile,
      duration: duration,
      thumbnail: thumbnail,
    );
  }

  static Future<Duration?> _resolveAudioDuration(File file) async {
    final player = AudioPlayer();
    try {
      await player.setFilePath(file.path);
      return player.duration;
    } catch (_) {
      return null;
    } finally {
      await player.dispose();
    }
  }

  static Future<(Duration?, File?)> _resolveVideoMetadata(
    File file,
    Directory thumbnailDirectory,
  ) async {
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(file);
      await controller.initialize();
      final duration = controller.value.duration;

      final baseName = p.basenameWithoutExtension(file.path);
      final thumbFilePath = p.join(thumbnailDirectory.path, '$baseName.png');

      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: file.path,
        thumbnailPath: thumbFilePath,
        imageFormat: ImageFormat.PNG,
        maxHeight: 320,
        timeMs: 0,
        quality: 80,
      );

      final filePath = thumbPath == null ? null : File(thumbPath);
      return (duration, filePath);
    } catch (_) {
      return (null, null);
    } finally {
      await controller?.dispose();
    }
  }

  static bool _hasExtension(File file, Set<String> extensions) {
    final path = file.path.toLowerCase();
    return extensions.any(path.endsWith);
  }
}
