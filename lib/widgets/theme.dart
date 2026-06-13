import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────
// § 3 — Complete Brand Color Palette (10 shades per group)
// ─────────────────────────────────────────────────────────────────

class IrmaColors {
  // Mindful Brown
  static const Color brown10 = Color(0xFFF7F4F2);
  static const Color brown20 = Color(0xFFE8DDD9);
  static const Color brown30 = Color(0xFFD5C2B9);
  static const Color brown40 = Color(0xFFBDA193);
  static const Color brown50 = Color(0xFFAC836C);
  static const Color brown60 = Color(0xFF926247);
  static const Color brown70 = Color(0xFF6D4B36);
  static const Color brown80 = Color(0xFF4B3425);
  static const Color brown90 = Color(0xFF332419);
  static const Color brown100 = Color(0xFF1F160F);

  // Optimistic Gray
  static const Color gray10 = Color(0xFFF2F5F8);
  static const Color gray20 = Color(0xFFDDE1E6);
  static const Color gray30 = Color(0xFFC1C6CD);
  static const Color gray40 = Color(0xFFA2A9B0);
  static const Color gray50 = Color(0xFF878E96);
  static const Color gray60 = Color(0xFF697077);
  static const Color gray70 = Color(0xFF4D5358);
  static const Color gray80 = Color(0xFF343A3F);
  static const Color gray90 = Color(0xFF21262A);
  static const Color gray100 = Color(0xFF121619);

  // Serenity Green
  static const Color green10 = Color(0xFFF2F5EB);
  static const Color green20 = Color(0xFFE5EAD7);
  static const Color green30 = Color(0xFFCFD9B5);
  static const Color green40 = Color(0xFFB4C48D);
  static const Color green50 = Color(0xFF9BB068);
  static const Color green60 = Color(0xFF7D944D);
  static const Color green70 = Color(0xFF5A6B38);
  static const Color green80 = Color(0xFF3D4A26);
  static const Color green90 = Color(0xFF29321A);
  static const Color green100 = Color(0xFF191E10);

  // Empathy Orange
  static const Color orange10 = Color(0xFFFFF0EB);
  static const Color orange20 = Color(0xFFFFD2C2);
  static const Color orange30 = Color(0xFFFEAF8F);
  static const Color orange40 = Color(0xFFFE814B);
  static const Color orange50 = Color(0xFFFE631B);
  static const Color orange60 = Color(0xFFDF4B01);
  static const Color orange70 = Color(0xFFA23901);
  static const Color orange80 = Color(0xFF702901);
  static const Color orange90 = Color(0xFF4C1D00);
  static const Color orange100 = Color(0xFF2E1200);

  // Zen Yellow
  static const Color yellow10 = Color(0xFFFFF4E0);
  static const Color yellow20 = Color(0xFFFFEBC2);
  static const Color yellow30 = Color(0xFFFFDB8F);
  static const Color yellow40 = Color(0xFFFFCE5C);
  static const Color yellow50 = Color(0xFFFFBC19);
  static const Color yellow60 = Color(0xFFE0A500);
  static const Color yellow70 = Color(0xFFA37A00);
  static const Color yellow80 = Color(0xFF705600);
  static const Color yellow90 = Color(0xFF4D3C00);
  static const Color yellow100 = Color(0xFF2E2500);

  // Gentle Purple
  static const Color purple10 = Color(0xFFEDEBFF);
  static const Color purple20 = Color(0xFFCBC2FF);
  static const Color purple30 = Color(0xFFA18FFF);
  static const Color purple40 = Color(0xFF7152FF);
  static const Color purple50 = Color(0xFF5530E8);
  static const Color purple60 = Color(0xFF3D16CA);
  static const Color purple70 = Color(0xFF2F1093);
  static const Color purple80 = Color(0xFF1C0070);
  static const Color purple90 = Color(0xFF14004D);
  static const Color purple100 = Color(0xFF0D002E);
}

// ─────────────────────────────────────────────────────────────────
// § 2 — Text Style Scale
// ─────────────────────────────────────────────────────────────────

class IrmaTextStyles {
  static bool get _isTestEnv => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  static TextStyle _urbanist({required double fontSize, required FontWeight fontWeight}) {
    if (_isTestEnv) {
      return TextStyle(fontFamily: 'Roboto', fontSize: fontSize, fontWeight: fontWeight);
    }
    return GoogleFonts.urbanist(fontSize: fontSize, fontWeight: fontWeight);
  }

  // Display LG (180)
  static TextStyle get displayLgBold => _urbanist(fontSize: 180, fontWeight: FontWeight.w700);
  static TextStyle get displayLgExtraBold => _urbanist(fontSize: 180, fontWeight: FontWeight.w800);

  // Display MD (128)
  static TextStyle get displayMdBold => _urbanist(fontSize: 128, fontWeight: FontWeight.w700);
  static TextStyle get displayMdExtraBold => _urbanist(fontSize: 128, fontWeight: FontWeight.w800);

  // Display SM (96)
  static TextStyle get displaySmBold => _urbanist(fontSize: 96, fontWeight: FontWeight.w700);
  static TextStyle get displaySmExtraBold => _urbanist(fontSize: 96, fontWeight: FontWeight.w800);

  // Heading 2XL (72)
  static TextStyle get heading2xlBold => _urbanist(fontSize: 72, fontWeight: FontWeight.w700);
  static TextStyle get heading2xlSemibold => _urbanist(fontSize: 72, fontWeight: FontWeight.w600);
  static TextStyle get heading2xlMedium => _urbanist(fontSize: 72, fontWeight: FontWeight.w500);

  // Heading XL (48)
  static TextStyle get headingXlBold => _urbanist(fontSize: 48, fontWeight: FontWeight.w700);
  static TextStyle get headingXlSemibold => _urbanist(fontSize: 48, fontWeight: FontWeight.w600);
  static TextStyle get headingXlMedium => _urbanist(fontSize: 48, fontWeight: FontWeight.w500);

  // Heading LG (30)
  static TextStyle get headingLgBold => _urbanist(fontSize: 30, fontWeight: FontWeight.w700);
  static TextStyle get headingLgSemibold => _urbanist(fontSize: 30, fontWeight: FontWeight.w600);
  static TextStyle get headingLgMedium => _urbanist(fontSize: 30, fontWeight: FontWeight.w500);

  // Heading MD (24)
  static TextStyle get headingMdBold => _urbanist(fontSize: 24, fontWeight: FontWeight.w700);
  static TextStyle get headingMdSemibold => _urbanist(fontSize: 24, fontWeight: FontWeight.w600);
  static TextStyle get headingMdMedium => _urbanist(fontSize: 24, fontWeight: FontWeight.w500);

  // Heading SM (20)
  static TextStyle get headingSmBold => _urbanist(fontSize: 20, fontWeight: FontWeight.w700);
  static TextStyle get headingSmSemibold => _urbanist(fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle get headingSmMedium => _urbanist(fontSize: 20, fontWeight: FontWeight.w500);

  // Heading XS (18)
  static TextStyle get headingXsBold => _urbanist(fontSize: 18, fontWeight: FontWeight.w700);
  static TextStyle get headingXsSemibold => _urbanist(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get headingXsMedium => _urbanist(fontSize: 18, fontWeight: FontWeight.w500);

  // Label 2XL (20)
  static TextStyle get label2xlBold => _urbanist(fontSize: 20, fontWeight: FontWeight.w700);

  // Label XL (18)
  static TextStyle get labelXlBold => _urbanist(fontSize: 18, fontWeight: FontWeight.w700);

  // Label LG (16)
  static TextStyle get labelLgBold => _urbanist(fontSize: 16, fontWeight: FontWeight.w700);

  // Label MD (14)
  static TextStyle get labelMdBold => _urbanist(fontSize: 14, fontWeight: FontWeight.w700);

  // Label SM (12)
  static TextStyle get labelSmBold => _urbanist(fontSize: 12, fontWeight: FontWeight.w700);

  // Label XS (10)
  static TextStyle get labelXsBold => _urbanist(fontSize: 10, fontWeight: FontWeight.w700);

  // Paragraph 2XL (24)
  static TextStyle get paragraph2xlSemibold => _urbanist(fontSize: 24, fontWeight: FontWeight.w600);
  static TextStyle get paragraph2xlMedium => _urbanist(fontSize: 24, fontWeight: FontWeight.w500);
  static TextStyle get paragraph2xlRegular => _urbanist(fontSize: 24, fontWeight: FontWeight.w400);

  // Paragraph XL (20)
  static TextStyle get paragraphXlSemibold => _urbanist(fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle get paragraphXlMedium => _urbanist(fontSize: 20, fontWeight: FontWeight.w500);
  static TextStyle get paragraphXlRegular => _urbanist(fontSize: 20, fontWeight: FontWeight.w400);

  // Paragraph LG (18)
  static TextStyle get paragraphLgSemibold => _urbanist(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get paragraphLgMedium => _urbanist(fontSize: 18, fontWeight: FontWeight.w500);
  static TextStyle get paragraphLgRegular => _urbanist(fontSize: 18, fontWeight: FontWeight.w400);

  // Paragraph MD (16)
  static TextStyle get paragraphMdSemibold => _urbanist(fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle get paragraphMdMedium => _urbanist(fontSize: 16, fontWeight: FontWeight.w500);
  static TextStyle get paragraphMdRegular => _urbanist(fontSize: 16, fontWeight: FontWeight.w400);

  // Paragraph SM (14)
  static TextStyle get paragraphSmSemibold => _urbanist(fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle get paragraphSmMedium => _urbanist(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle get paragraphSmRegular => _urbanist(fontSize: 14, fontWeight: FontWeight.w400);

  // Paragraph XS (12)
  static TextStyle get paragraphXsSemibold => _urbanist(fontSize: 12, fontWeight: FontWeight.w600);
  static TextStyle get paragraphXsMedium => _urbanist(fontSize: 12, fontWeight: FontWeight.w500);
  static TextStyle get paragraphXsRegular => _urbanist(fontSize: 12, fontWeight: FontWeight.w400);

  // Legacy aliases for backwards compatibility
  static TextStyle get displayLg => displayLgBold;
  static TextStyle get displayMd => displayMdBold;
  static TextStyle get displaySm => displaySmBold;
  static TextStyle get heading2xl => heading2xlBold;
  static TextStyle get para2xl => paragraph2xlMedium;
  static TextStyle get paraXl => paragraphXlMedium;
  static TextStyle get paraLg => paragraphLgMedium;
  static TextStyle get paraMd => paragraphMdMedium;
  static TextStyle get paraSm => paragraphSmRegular;
  static TextStyle get paraXs => paragraphXsMedium;
  static TextStyle get label2xl => label2xlBold;
  static TextStyle get labelXl => labelXlBold;
  static TextStyle get labelLg => labelLgBold;
  static TextStyle get labelMd => labelMdBold;
  static TextStyle get labelSm => labelSmBold;
  static TextStyle get labelXs => labelXsBold;
}

// ─────────────────────────────────────────────────────────────────
// Spacing constants
// ─────────────────────────────────────────────────────────────────

class IrmaSpacing {
  static const double xs  = 8;
  static const double sm  = 12;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}

// ─────────────────────────────────────────────────────────────────
// Radius tokens (copied strictly from ui_design_system.md)
// ─────────────────────────────────────────────────────────────────

class IrmaRadius {
  static const double large = 32.0;       // Large Layout Cards, Standard Action Cards, Brand Logo, Onboarding Indicators, Chat Feed Container, Profile Picture, Tab Bar Container
  static const double standard = 32.0;    // Standard Action Cards
  static const double stat = 24.0;        // Statistic & Content Cards, Score History
  static const double log = 24.0;         // Score History & Log List Cards
  static const double picker = 48.0;      // Sleep Hour Picker
  static const double pill = 1000.0;      // Pill shape / fully rounded (e.g. tag, button, chat text bubble)
}

// ─────────────────────────────────────────────────────────────────
// Padding tokens (copied strictly from ui_design_system.md)
// ─────────────────────────────────────────────────────────────────

class IrmaPadding {
  // Cards
  static const EdgeInsets cardLarge = EdgeInsets.all(24.0);
  static const EdgeInsets cardStandard = EdgeInsets.all(16.0);
  static const EdgeInsets cardStat = EdgeInsets.all(16.0);
  static const EdgeInsets cardLog = EdgeInsets.all(12.0);
  
  // Tags
  static const EdgeInsets tagXs = EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0);
  static const EdgeInsets tagSm = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
  static const EdgeInsets tagMd = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  static const EdgeInsets tagLg = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
  static const EdgeInsets tagXl = EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0);

  // Component containers
  static const EdgeInsets inputForm = EdgeInsets.all(24.0);
  static const EdgeInsets logo = EdgeInsets.all(16.0);
  static const EdgeInsets welcomeIndicator = EdgeInsets.all(24.0);
  static const EdgeInsets chatHeader = EdgeInsets.all(16.0);
  static const EdgeInsets chatFeed = EdgeInsets.all(24.0);
  static const EdgeInsets chatInput = EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 16.0);
  static const EdgeInsets profilePicture = EdgeInsets.all(24.0);
  static const EdgeInsets tabBar = EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0);
}

// ─────────────────────────────────────────────────────────────────
// Specialized decorations (copied strictly from ui_design_system.md)
// ─────────────────────────────────────────────────────────────────

class IrmaDecorations {
  static BoxDecoration dateRange({required bool selected}) => BoxDecoration(
    color: selected ? IrmaColors.brown80 : IrmaColors.brown10,
    borderRadius: BorderRadius.circular(IrmaRadius.pill),
  );

  static BoxDecoration aiModelRadio({required bool selected}) => BoxDecoration(
    color: selected ? IrmaColors.green50 : Colors.white,
    borderRadius: BorderRadius.circular(IrmaRadius.pill),
  );

  static BoxDecoration toggle({required bool value}) => BoxDecoration(
    color: value ? IrmaColors.green50 : IrmaColors.brown20,
    borderRadius: BorderRadius.circular(IrmaRadius.pill),
  );

  static BoxDecoration iconButton() => BoxDecoration(
    color: IrmaColors.orange40,
    borderRadius: BorderRadius.circular(IrmaRadius.pill),
  );

  static BoxDecoration conversationStylePill({required bool selected}) => BoxDecoration(
    color: selected ? IrmaColors.green10 : Colors.white,
    borderRadius: BorderRadius.circular(IrmaRadius.pill),
  );
}

// ─────────────────────────────────────────────────────────────────
// § 4 — Button Style Factories
// ─────────────────────────────────────────────────────────────────

class IrmaButtonStyles {
  static const double _pillRadius = 1000;

  /// Brown 80 fill, white label — large size (32/16 padding)
  static ButtonStyle primaryLg() => ElevatedButton.styleFrom(
    backgroundColor: IrmaColors.brown80,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.xl, vertical: IrmaSpacing.md),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_pillRadius))),
    elevation: 0,
    textStyle: IrmaTextStyles.labelLg,
  );

  /// Brown 80 fill, white label — medium size (24/16 padding)
  static ButtonStyle primaryMd() => ElevatedButton.styleFrom(
    backgroundColor: IrmaColors.brown80,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: IrmaSpacing.md),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_pillRadius))),
    elevation: 0,
    textStyle: IrmaTextStyles.labelLg,
  );

  /// Brown 80 fill, white label — small size (20/8 padding)
  static ButtonStyle primarySm() => ElevatedButton.styleFrom(
    backgroundColor: IrmaColors.brown80,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: IrmaSpacing.xs),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_pillRadius))),
    elevation: 0,
    textStyle: IrmaTextStyles.labelMd,
  );

  /// Brown 10 fill, Brown 80 label — large (32/16 padding)
  static ButtonStyle secondaryLg() => ElevatedButton.styleFrom(
    backgroundColor: IrmaColors.brown10,
    foregroundColor: IrmaColors.brown80,
    padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.xl, vertical: IrmaSpacing.md),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_pillRadius))),
    elevation: 0,
    textStyle: IrmaTextStyles.labelLg,
  );

  /// Transparent fill, Brown 80 outline & label — large (32/16 padding)
  static ButtonStyle outlinedLg() => OutlinedButton.styleFrom(
    foregroundColor: IrmaColors.brown80,
    padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.xl, vertical: IrmaSpacing.md),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_pillRadius))),
    side: const BorderSide(color: IrmaColors.brown80),
    textStyle: IrmaTextStyles.labelLg,
  );

  /// Transparent fill, Brown 80 outline & label — medium
  static ButtonStyle outlinedMd() => OutlinedButton.styleFrom(
    foregroundColor: IrmaColors.brown80,
    padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: IrmaSpacing.md),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_pillRadius))),
    side: const BorderSide(color: IrmaColors.brown80),
    textStyle: IrmaTextStyles.labelLg,
  );
}

// ─────────────────────────────────────────────────────────────────
// § 6 — Card Decoration Factories
// ─────────────────────────────────────────────────────────────────

class IrmaCards {
  /// Large layout card — radius 32, 24px padding, gray20 border
  static BoxDecoration large({Color fill = Colors.white, Color? border}) => BoxDecoration(
    color: fill,
    borderRadius: BorderRadius.circular(32),
    border: Border.all(color: border ?? IrmaColors.gray20),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
  );

  /// Standard action card — radius 32, 16px padding, white fill
  static BoxDecoration standard({Color fill = Colors.white, Color? border}) => BoxDecoration(
    color: fill,
    borderRadius: BorderRadius.circular(32),
    border: Border.all(color: border ?? IrmaColors.gray20),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
  );

  /// Stat / content card — radius 24, 16px padding, white fill
  static BoxDecoration stat({Color fill = Colors.white, Color? border}) => BoxDecoration(
    color: fill,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: border ?? IrmaColors.gray20),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
  );

  /// Score / log list card — radius 24, 12px padding, gray10 fill
  static BoxDecoration log({Color? border}) => BoxDecoration(
    color: IrmaColors.gray10,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: border ?? IrmaColors.gray20),
  );

  /// Advice/insight card — green10 fill, green30 border
  static BoxDecoration advice() => BoxDecoration(
    color: IrmaColors.green10,
    borderRadius: BorderRadius.circular(32),
    border: Border.all(color: IrmaColors.green30),
  );

  /// Error/OTP bubble — orange20 fill, pill shape
  static BoxDecoration error() => BoxDecoration(
    color: IrmaColors.orange20,
    borderRadius: BorderRadius.circular(1000),
  );
}

// ─────────────────────────────────────────────────────────────────
// § 8 — Input Field Decoration Factory
// ─────────────────────────────────────────────────────────────────

class IrmaInputDecoration {
  /// Master input form — radius 32, 24px padding, 1px green50 border
  static InputDecoration standard({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? labelText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.brown70),
      labelText: labelText,
      labelStyle: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.gray60),
      floatingLabelStyle: IrmaTextStyles.labelSm.copyWith(color: IrmaColors.green50),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: IrmaSpacing.lg),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: IrmaColors.green50),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: IrmaColors.green30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: IrmaColors.green50, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: IrmaColors.orange40),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Legacy IrmaTheme — forwards to new tokens for backwards compat
// ─────────────────────────────────────────────────────────────────

class IrmaTheme {
  // Semantic aliases kept for existing view references
  static const Color darkEspresso  = IrmaColors.brown100;
  static const Color earthyBrown   = IrmaColors.brown80;
  static const Color mediumBrown   = IrmaColors.brown60;
  static const Color lightTan      = IrmaColors.brown20;
  static const Color lightWarmGray = IrmaColors.brown10;
  static const Color sageGreen     = IrmaColors.green50;
  static const Color lightGreen    = IrmaColors.green30;
  static const Color lightSageTint = IrmaColors.green10;
  static const Color empathyOrange = IrmaColors.orange40;
  static const Color lightOrangeTint = IrmaColors.orange10;
  static const Color zenYellow     = IrmaColors.yellow40;
  static const Color lightYellowTint = IrmaColors.yellow10;
  static const Color gentlePurple  = IrmaColors.purple40;
  static const Color lightPurple   = IrmaColors.purple20;
  static const Color lightPurpleTint = IrmaColors.purple10;
  static const Color gray10        = IrmaColors.gray10;
  static const Color gray20        = IrmaColors.gray20;
  static const Color gray30        = IrmaColors.gray30;
  static const Color gray60        = IrmaColors.gray60;
  static const Color gray100       = IrmaColors.gray100;

  /// Backwards-compatible card decoration (wraps IrmaCards.large)
  static BoxDecoration cardDecoration({
    Color color = Colors.white,
    double radius = 32.0,
    Color? borderColor,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? IrmaColors.gray20, width: borderWidth),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
    );
  }

  /// App-wide ThemeData
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    fontFamily: 'Urbanist',
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: IrmaColors.green50,
      secondary: IrmaColors.brown80,
      surface: Colors.white,
      onSurface: IrmaColors.brown100,
      error: IrmaColors.orange40,
    ),
    textTheme: TextTheme(
      displayLarge:  IrmaTextStyles.displaySmBold.copyWith(color: IrmaColors.brown80),
      headlineLarge: IrmaTextStyles.heading2xlBold.copyWith(color: IrmaColors.brown80),
      headlineMedium: IrmaTextStyles.headingLgBold.copyWith(color: IrmaColors.brown80), // size 30
      titleLarge:    IrmaTextStyles.label2xlBold.copyWith(color: IrmaColors.brown100),
      bodyLarge:     IrmaTextStyles.paragraphMdMedium.copyWith(color: IrmaColors.brown100),
      bodyMedium:    IrmaTextStyles.paragraphSmRegular.copyWith(color: IrmaColors.gray60),
      labelLarge:    IrmaTextStyles.labelLgBold.copyWith(color: Colors.white),
      labelMedium:   IrmaTextStyles.labelMdBold.copyWith(color: IrmaColors.brown100),
      labelSmall:    IrmaTextStyles.labelSmBold.copyWith(color: IrmaColors.gray60),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: IrmaButtonStyles.primaryLg()),
    outlinedButtonTheme: OutlinedButtonThemeData(style: IrmaButtonStyles.outlinedLg()),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: IrmaSpacing.lg),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: IrmaColors.green50)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: IrmaColors.green30)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: IrmaColors.green50, width: 2)),
      hintStyle: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.brown70),
      filled: true,
      fillColor: Colors.white,
    ),
    dividerColor: IrmaColors.brown20,
    dividerTheme: const DividerThemeData(color: IrmaColors.brown20, thickness: 1, space: 0),
  );
}
