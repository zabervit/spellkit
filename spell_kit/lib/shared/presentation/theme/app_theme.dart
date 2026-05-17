import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.electricBlue,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          displayLarge: GoogleFonts.nunito(
              fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.onSurface),
          displayMedium: GoogleFonts.nunito(
              fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.onSurface),
          headlineLarge: GoogleFonts.nunito(
              fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface),
          headlineMedium: GoogleFonts.nunito(
              fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
      );
}
