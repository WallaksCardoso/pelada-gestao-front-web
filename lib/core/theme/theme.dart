import 'package:flutter/material.dart';

class Cores {
  static const Color azul = Color(0xFF3B82F6);
  static const Color vermelho = Color(0xFFEF4444);
  static const Color goleiro = Color(0xFFF59E0B);
}

class _Paleta {
  final Color fundo;
  final Color superficie;
  final Color superficieAlta;
  final Color borda;
  final Color texto;
  final Color textoSuave;
  final Color destaque;
  final Color sobreDestaque;

  const _Paleta({
    required this.fundo,
    required this.superficie,
    required this.superficieAlta,
    required this.borda,
    required this.texto,
    required this.textoSuave,
    required this.destaque,
    required this.sobreDestaque,
  });
}

class AppTheme {
  static const _escura = _Paleta(
    fundo: Color(0xFF0B1210),
    superficie: Color(0xFF121B18),
    superficieAlta: Color(0xFF1A2622),
    borda: Color(0xFF24332D),
    texto: Color(0xFFE7EFEA),
    textoSuave: Color(0xFF8FA39A),
    destaque: Color(0xFF22C55E),
    sobreDestaque: Color(0xFF04140B),
  );

  static const _clara = _Paleta(
    fundo: Color(0xFFF4F7F5),
    superficie: Color(0xFFFFFFFF),
    superficieAlta: Color(0xFFEDF2EF),
    borda: Color(0xFFD8E2DC),
    texto: Color(0xFF0F1A15),
    textoSuave: Color(0xFF5B6B63),
    destaque: Color(0xFF16A34A),
    sobreDestaque: Color(0xFFFFFFFF),
  );

  static final ThemeData escuro = _tema(Brightness.dark, _escura);
  static final ThemeData claro = _tema(Brightness.light, _clara);

  static ThemeData _tema(Brightness brilho, _Paleta p) {
    final esquema = ColorScheme(
      brightness: brilho,
      primary: p.destaque,
      onPrimary: p.sobreDestaque,
      secondary: p.destaque,
      onSecondary: p.sobreDestaque,
      error: Cores.vermelho,
      onError: Colors.white,
      surface: p.superficie,
      onSurface: p.texto,
      onSurfaceVariant: p.textoSuave,
      surfaceContainerHighest: p.superficieAlta,
      outline: p.borda,
      outlineVariant: p.borda,
    );

    final cantos = BorderRadius.circular(12);

    return ThemeData(
      useMaterial3: true,
      brightness: brilho,
      colorScheme: esquema,
      scaffoldBackgroundColor: p.fundo,
      dividerColor: p.borda,
      appBarTheme: AppBarTheme(
        backgroundColor: p.fundo,
        foregroundColor: p.texto,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: p.texto,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.borda),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.superficieAlta,
        labelStyle: TextStyle(color: p.textoSuave),
        floatingLabelStyle: TextStyle(color: p.destaque),
        prefixIconColor: p.textoSuave,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: cantos,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: cantos,
          borderSide: BorderSide(color: p.borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: cantos,
          borderSide: BorderSide(color: p.destaque, width: 2),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.destaque,
        selectionColor: p.destaque.withValues(alpha: 0.3),
        selectionHandleColor: p.destaque,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: cantos),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: p.texto,
          side: BorderSide(color: p.borda),
          shape: RoundedRectangleBorder(borderRadius: cantos),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.destaque,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.destaque,
        foregroundColor: p.sobreDestaque,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: p.superficie,
          foregroundColor: p.textoSuave,
          selectedBackgroundColor: p.destaque.withValues(alpha: 0.16),
          selectedForegroundColor: p.destaque,
          side: BorderSide(color: p.borda),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.superficieAlta,
        selectedColor: Cores.goleiro.withValues(alpha: 0.2),
        side: BorderSide(color: p.borda),
        labelStyle: TextStyle(color: p.texto, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.superficie,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: cantos),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.destaque),
    );
  }
}
