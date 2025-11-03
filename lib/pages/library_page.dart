import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/media_item.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../widgets/eli_scaffold_container.dart';
import '../widgets/media_item_tile.dart';
import '../widgets/media_player_sheet.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, required this.libraryService});

  final LibraryService libraryService;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshLibrary();
  }

  Future<void> _refreshLibrary() async {
    setState(() {
      _refreshing = true;
      _error = null;
    });
    try {
      await widget.libraryService.refresh();
    } catch (error) {
      setState(() {
        _error = 'No se pudo cargar la biblioteca: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return EliScaffoldContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ValueListenableBuilder<List<MediaItem>>(
        valueListenable: widget.libraryService.mediaItems,
        builder: (context, items, _) {
          if (_error != null) {
            return _buildErrorState();
          }
          if (items.isEmpty && !_refreshing) {
            return _buildEmptyState();
          }

          return RefreshIndicator.adaptive(
            onRefresh: _refreshLibrary,
            color: AppColors.mint,
            child: items.isEmpty
                ? ListView(children: const [SizedBox(height: 260)])
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return MediaItemTile(
                        item: item,
                        onPlay: () => _openPlayer(item),
                        onDelete: () => _deleteItem(item),
                      ).animate().fadeIn(duration: 300.ms).slide(begin: const Offset(0, 0.05));
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.cloud_download_rounded, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('Aún no tienes descargas.'),
          SizedBox(height: 4),
          Text(
            'Descarga videos o audios desde la pestaña Descargas.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ).animate().fade(duration: 400.ms),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(_error ?? 'Error'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _refreshLibrary,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(MediaItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar archivo'),
          content: Text('¿Quieres eliminar "${item.title}" de tu biblioteca?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
          ],
        );
      },
    );

    if (confirmed == true) {
      await widget.libraryService.delete(item);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo eliminado: ${item.title}')),
      );
    }
  }

  Future<void> _openPlayer(MediaItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaPlayerSheet(item: item),
    );
  }
}
