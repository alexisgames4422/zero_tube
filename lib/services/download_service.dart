import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/download_state.dart';
import 'library_service.dart';

class DownloadService {
  DownloadService(this._libraryService);

  final LibraryService _libraryService;

  bool get supportsDownloads {
    return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  Future<DownloadState> download(
    String url, {
    required bool audioOnly,
    void Function(DownloadProgress progress)? onProgress,
  }) async {
    if (url.isEmpty) {
      return DownloadState.failed('Ingresa una URL de YouTube.');
    }

    if (!supportsDownloads) {
      return DownloadState.failed('Las descargas solo están disponibles en Windows, Linux y macOS.');
    }

    final downloadsDir = await _libraryService.getMediaDirectory();

    final args = _buildArguments(url, downloadsDir.path, audioOnly: audioOnly);

    try {
      final process = await Process.start(
        'yt-dlp',
        args,
        workingDirectory: downloadsDir.path,
        runInShell: Platform.isWindows,
      );

      final subscriptions = <StreamSubscription>[];

      void emit(DownloadProgress progress) {
        onProgress?.call(progress);
      }

      subscriptions.add(
        process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
          final progress = _parseProgress(line);
          if (progress != null) {
            emit(progress);
          }
        }),
      );

      subscriptions.add(
        process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
          emit(DownloadProgress(message: line));
        }),
      );

      final exitCode = await process.exitCode;
      await Future.wait(subscriptions.map((sub) => sub.cancel()));

      if (exitCode == 0) {
        await _libraryService.onDownloadCompleted();
        emit(const DownloadProgress(percent: 1.0, message: 'Descarga completada'));
        return DownloadState.completed();
      }

      return DownloadState.failed('Error al descargar. Código: $exitCode');
    } on ProcessException catch (error) {
      return DownloadState.failed(
        'No se pudo iniciar yt-dlp. Verifica que esté instalado y disponible en el PATH. Detalle: ${error.message}',
      );
    } catch (error) {
      return DownloadState.failed('Error inesperado: $error');
    }
  }

  List<String> _buildArguments(String url, String downloadsPath, {required bool audioOnly}) {
    final outputTemplate = p.join(downloadsPath, '%(title)s.%(ext)s');
    final args = <String>[
      url,
      '--no-playlist',
      '--newline',
      '--progress',
      '--output',
      outputTemplate,
    ];

    if (audioOnly) {
      args.addAll(['--extract-audio', '--audio-format', 'mp3']);
    } else {
      args.addAll(['-f', 'bv*+ba/b']);
    }

    return args;
  }

  DownloadProgress? _parseProgress(String line) {
    final percentExp = RegExp(r'(\\d{1,3}(?:\\.\\d+)?)%');
    if (percentExp.hasMatch(line)) {
      final match = percentExp.firstMatch(line);
      final percentString = match?.group(1);
      if (percentString != null) {
        final percent = double.tryParse(percentString);
        if (percent != null) {
          return DownloadProgress(percent: percent / 100.0, message: line.trim());
        }
      }
    }
    if (line.toLowerCase().contains('error') || line.toLowerCase().contains('failed')) {
      return DownloadProgress(message: line.trim());
    }
    return null;
  }
}
