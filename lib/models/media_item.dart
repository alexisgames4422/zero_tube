import 'dart:io';

class MediaItem {
  MediaItem({
    required this.file,
    required this.title,
    required this.isVideo,
    required this.duration,
    this.thumbnail,
  });

  final File file;
  final String title;
  final bool isVideo;
  final Duration? duration;
  final File? thumbnail;

  String get formattedDuration {
    if (duration == null) return '--:--';
    final minutes = duration!.inMinutes.remainder(60).toString().padLeft(2, '0');
    final hours = duration!.inHours;
    final seconds = duration!.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}
