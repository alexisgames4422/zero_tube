import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/media_item.dart';
import '../utils/media_metadata.dart';

class LibraryService {
  LibraryService();

  final ValueNotifier<List<MediaItem>> mediaItems = ValueNotifier<List<MediaItem>>([]);

  Directory? _mediaDirectory;
  Directory? _thumbnailDirectory;
  bool _initializing = false;

  Future<void> initialize() async {
    if (_initializing) return;
    _initializing = true;
    try {
      await _ensureDirectories();
      await refresh();
    } finally {
      _initializing = false;
    }
  }

  Future<Directory> getMediaDirectory() async {
    return _ensureDirectories();
  }

  Directory? get thumbnailDirectory => _thumbnailDirectory;

  Future<void> refresh() async {
    final directory = await _ensureDirectories();
    final thumbnailDir = _thumbnailDirectory;
    if (!directory.existsSync() || thumbnailDir == null) {
      mediaItems.value = [];
      return;
    }

    final files = await directory
        .list()
        .where((entity) => entity is File && _isSupported(entity.path))
        .cast<File>()
        .toList();

    files.sort((a, b) {
      final aTime = a.statSync().modified;
      final bTime = b.statSync().modified;
      return bTime.compareTo(aTime);
    });

    final List<MediaItem> items = [];
    for (final file in files) {
      final item = await MediaMetadataResolver.resolve(file, thumbnailDir);
      items.add(item);
    }
    mediaItems.value = items;
  }

  Future<void> delete(MediaItem item) async {
    try {
      if (await item.file.exists()) {
        await item.file.delete();
      }
      if (item.thumbnail != null && await item.thumbnail!.exists()) {
        await item.thumbnail!.delete();
      }
    } finally {
      await refresh();
    }
  }

  Future<void> onDownloadCompleted() async {
    await refresh();
  }

  Future<Directory> _ensureDirectories() async {
    if (_mediaDirectory != null && _thumbnailDirectory != null) {
      return _mediaDirectory!;
    }

    final base = await _resolveBaseDirectory();
    final mediaDir = Directory(p.join(base.path, 'EliPlayer', 'media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    final thumbDir = Directory(p.join(mediaDir.path, '.thumbnails'));
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }

    _mediaDirectory = mediaDir;
    _thumbnailDirectory = thumbDir;
    return mediaDir;
  }

  Future<Directory> _resolveBaseDirectory() async {
    if (Platform.isAndroid) {
      return await getApplicationDocumentsDirectory();
    }
    if (Platform.isLinux || Platform.isWindows) {
      return await getApplicationSupportDirectory();
    }
    if (Platform.isMacOS) {
      return await getLibraryDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

  bool _isSupported(String path) {
    final file = File(path);
    return MediaMetadataResolver.isAudio(file) || MediaMetadataResolver.isVideo(file);
  }
}
