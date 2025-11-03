import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/home_page.dart';
import 'theme/app_theme.dart';

class EliPlayerApp extends StatelessWidget {
  const EliPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eli Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
      builder: (context, child) {
        final textTheme = Theme.of(context).textTheme;
        return DefaultTextStyle(
          style: GoogleFonts.poppins(textStyle: textTheme.bodyMedium!),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
