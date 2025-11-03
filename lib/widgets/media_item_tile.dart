import 'dart:io';

import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../theme/app_theme.dart';

class MediaItemTile extends StatelessWidget {
  const MediaItemTile({
    super.key,
    required this.item,
    required this.onPlay,
    required this.onDelete,
  });

  final MediaItem item;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onPlay,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _ThumbnailPreview(item: item),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(item.isVideo ? Icons.movie_rounded : Icons.graphic_eq_rounded,
                            size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          item.isVideo ? 'Video' : 'Audio',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        if (item.duration != null)
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                item.formattedDuration,
                                style:
                                    const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onPlay,
                    icon: const Icon(Icons.play_arrow_rounded),
                    tooltip: 'Reproducir',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: 'Eliminar',
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

class _ThumbnailPreview extends StatelessWidget {
  const _ThumbnailPreview({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final file = item.thumbnail;

    if (file != null && file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(
          file,
          width: 86,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _PlaceholderIcon(isVideo: item.isVideo),
        ),
      );
    }

    return _PlaceholderIcon(isVideo: item.isVideo);
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon({required this.isVideo});

  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    final gradientColors = isVideo
        ? [AppColors.ice.withOpacity(0.8), AppColors.mint.withOpacity(0.6)]
        : [AppColors.mint.withOpacity(0.5), AppColors.surfaceVariant.withOpacity(0.7)];

    return Container(
      width: 86,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        isVideo ? Icons.movie_creation_rounded : Icons.graphic_eq_rounded,
        color: AppColors.background,
      ),
    );
  }
}
