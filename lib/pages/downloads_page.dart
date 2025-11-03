import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/download_state.dart';
import '../services/download_service.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../widgets/eli_scaffold_container.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key, required this.libraryService});

  final LibraryService libraryService;

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  late final DownloadService _downloadService;
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocus = FocusNode();

  bool _audioOnly = true;
  DownloadState _state = DownloadState.idle();
  DownloadProgress? _progress;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _downloadService = DownloadService(widget.libraryService);
    _statusMessage = _downloadService.supportsDownloads
        ? 'Pega la URL de YouTube para comenzar.'
        : 'Las descargas no están disponibles en esta plataforma.';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EliScaffoldContainer(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUrlField(),
            const SizedBox(height: 16),
            _buildAudioSwitch(),
            const SizedBox(height: 24),
            _buildDownloadButton(),
            const SizedBox(height: 24),
            if (_statusMessage != null) _buildStatusMessage(),
            const SizedBox(height: 12),
            _buildProgressBar(),
            const SizedBox(height: 12),
            _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlField() {
    return TextField(
      controller: _urlController,
      focusNode: _urlFocus,
      enabled: !_state.isDownloading,
      decoration: const InputDecoration(
        labelText: 'URL de YouTube',
        hintText: 'https://youtube.com/...' ,
        prefixIcon: Icon(Icons.link_rounded),
      ),
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _startDownload(),
    );
  }

  Widget _buildAudioSwitch() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Descargar como audio (MP3)'),
              SizedBox(height: 4),
              Text(
                'Activa para obtener solo el audio. Desactiva para descargar video (MP4).',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: _audioOnly,
          onChanged: _state.isDownloading
              ? null
              : (value) {
                  setState(() => _audioOnly = value);
                },
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    final canDownload = _downloadService.supportsDownloads && !_state.isDownloading;
    final label = _state.isDownloading ? 'Descargando...' : 'Iniciar descarga';

    return ElevatedButton.icon(
      onPressed: canDownload ? _startDownload : null,
      icon: Icon(_state.isDownloading ? Icons.hourglass_bottom_rounded : Icons.download_rounded),
      label: Text(label),
    ).animate(target: canDownload ? 1 : 0).scale(duration: 250.ms, curve: Curves.easeOut);
  }

  Widget _buildProgressBar() {
    final progressValue = _progress?.percent;

    return AnimatedSwitcher(
      duration: 250.ms,
      child: _state.isDownloading || (progressValue != null && progressValue > 0)
          ? Column(
              key: const ValueKey('progress'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(value: progressValue != null ? progressValue.clamp(0.0, 1.0) : null),
                if (_progress?.message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _progress!.message!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildStatusMessage() {
    final message = _statusMessage ?? '';
    final isError = _state.hasError;
    final color = isError ? Colors.redAccent : AppColors.textSecondary;

    return Text(
      message,
      style: TextStyle(color: color),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTipsCard() {
    return Card(
      color: AppColors.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Consejos',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('1. Instalá yt-dlp en tu sistema para habilitar las descargas.'),
            SizedBox(height: 4),
            Text('2. Usa URLs directas de videos (no listas de reproducción).'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slide(begin: const Offset(0, 0.05));
  }

  Future<void> _startDownload() async {
    if (_state.isDownloading) return;
    final url = _urlController.text.trim();

    final uri = Uri.tryParse(url);
    if (uri == null || (!uri.hasScheme || !uri.hasAuthority)) {
      setState(() {
        _state = DownloadState.failed('URL no válida');
        _statusMessage = 'Introduce una URL válida de YouTube.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce una URL válida de YouTube.')),
      );
      return;
    }

    setState(() {
      _state = DownloadState.inProgress();
      _progress = const DownloadProgress(percent: 0.0, message: 'Iniciando descarga...');
      _statusMessage = 'Preparando descarga...';
    });

    final result = await _downloadService.download(
      url,
      audioOnly: _audioOnly,
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _progress = progress;
          if (progress.message != null) {
            _statusMessage = progress.message;
          }
        });
      },
    );

    if (!mounted) return;

    setState(() {
      _state = result;
      if (result.completed) {
        _statusMessage = 'Descarga completada. Revisa tu biblioteca.';
      } else if (result.hasError) {
        _statusMessage = result.errorMessage;
      }
    });

    if (result.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descarga completada.')),
      );
      _urlController.clear();
      _urlFocus.requestFocus();
    } else if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Error al descargar.')),
      );
    }
  }
}
