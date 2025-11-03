import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/library_service.dart';
import 'downloads_page.dart';
import 'library_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final LibraryService _libraryService;
  late final List<_Destination> _destinations;

  @override
  void initState() {
    super.initState();
    _libraryService = LibraryService();
    unawaited(_libraryService.initialize());
    _destinations = [
      _Destination(
        title: 'Descargas',
        icon: Icons.download_rounded,
        page: DownloadsPage(libraryService: _libraryService),
      ),
      _Destination(
        title: 'Biblioteca',
        icon: Icons.video_library_rounded,
        page: LibraryPage(libraryService: _libraryService),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final destination = _destinations[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(destination.title),
      ),
      body: AnimatedSwitcher(
        duration: 350.ms,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(destination.title),
          child: destination.page
              .animate(key: ValueKey(_currentIndex))
              .fade(duration: 300.ms, curve: Curves.easeOut)
              .slide(begin: const Offset(0, 0.02), curve: Curves.easeOut),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == _currentIndex) return;
        setState(() => _currentIndex = index);
      },
      items: [
        for (final destination in _destinations)
          BottomNavigationBarItem(
            icon: Icon(destination.icon),
            label: destination.title,
          ),
      ],
    );
  }
}

class _Destination {
  const _Destination({
    required this.title,
    required this.icon,
    required this.page,
  });

  final String title;
  final IconData icon;
  final Widget page;
}
