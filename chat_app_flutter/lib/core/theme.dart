import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontSizes {
  static const small = 12.0;
  static const standard = 14.0;
  static const standardUp = 16.0;
  static const medium = 20.0;
  static const large = 28.0;
}

class DefaultColors {

  static const Color messageListPageLight = Color(0xFFD6D6D6);
  static const Color messageListPageDark =  Color(0xFF292F3F);

  static Color messageListPage(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? messageListPageDark
        : messageListPageLight;
  }

  static const Color greyText = Color(0xFFB3B9C9);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color senderMessage = Color(0xFF7A8194);
  static const Color receiverMessage = Color(0xFF373E4E);
  static const Color sentMessageInput = Color(0xFF304354);

  static const Color buttonColor = Color(0xFF7A8194);
  static const Color dailyQuestionColor = Colors.blueGrey;
}

class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: Colors.blue,
      secondary: DefaultColors.greyText,
      background: Color(0xFF18202D),
      surface: DefaultColors.receiverMessage,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: colorScheme.background,
      iconTheme: IconThemeData(color: Colors.white),
      textTheme: _buildTextTheme(Colors.white),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      floatingActionButtonTheme: _buildFABTheme(colorScheme),
      dialogTheme: _buildDialogTheme(colorScheme),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: Colors.blue,
      secondary: DefaultColors.greyText,
      background: Colors.white,
      surface: Colors.grey[100]!,
      onPrimary: Colors.white,
      onSurface: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: Colors.black,
      scaffoldBackgroundColor: colorScheme.background,
      iconTheme: IconThemeData(color: Colors.black),
      textTheme: _buildTextTheme(Colors.black),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      floatingActionButtonTheme: _buildFABTheme(colorScheme),
      dialogTheme: _buildDialogTheme(colorScheme),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      titleMedium: GoogleFonts.alegreyaSans(fontSize: FontSizes.medium, color: textColor),
      titleLarge: GoogleFonts.alegreyaSans(fontSize: FontSizes.large, color: textColor),
      bodySmall: GoogleFonts.alegreyaSans(fontSize: FontSizes.standard, color: textColor),
      displayLarge: GoogleFonts.alegreyaSans(fontSize: FontSizes.large, color: textColor),
      displayMedium: GoogleFonts.alegreyaSans(fontSize: FontSizes.standardUp, color: textColor),
      displaySmall: GoogleFonts.alegreyaSans(fontSize: FontSizes.medium, color: textColor),
      bodyLarge: GoogleFonts.alegreyaSans(fontSize: FontSizes.standard, color: textColor),
      bodyMedium: GoogleFonts.alegreyaSans(fontSize: FontSizes.standardUp, color: textColor),
      titleSmall: GoogleFonts.alegreyaSans(fontSize: FontSizes.small, color: textColor),
      labelLarge: GoogleFonts.alegreyaSans(fontSize: FontSizes.standardUp, color: textColor),
      labelSmall: GoogleFonts.alegreyaSans(fontSize: FontSizes.small, color: textColor),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  static FloatingActionButtonThemeData _buildFABTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    );
  }

  static DialogTheme _buildDialogTheme(ColorScheme colorScheme) {
    return DialogTheme(
      backgroundColor: colorScheme.surface,
      titleTextStyle: GoogleFonts.alegreyaSans(
        fontSize: FontSizes.medium,
        color: colorScheme.onSurface,
      ),
    );
  }
}