/// Configuration flags for web security features
class WebSecurityConfig {
  /// A: Disable right-click context menu
  static bool disableRightClick = true;

  /// B: Blur screen when tab/window loses visibility
  static bool blurOnVisibilityChange = true;

  /// C: Show watermark overlay
  static bool showWatermark = true;

  /// D: Disable debugPrint and print() globally
  static bool disableDebugPrint = false;

  /// Watermark text (usually user ID or name)
  static String watermarkText = '';

  /// Watermark font size
  static double watermarkFontSize = 14;

  /// Watermark opacity (0.0 - 1.0)
  static double watermarkOpacity = 0.08;

  /// Watermark rotation angle (radians)
  static double watermarkRotation = -0.5;

  /// Watermark horizontal spacing
  static double watermarkSpacingX = 200;

  /// Watermark vertical spacing
  static double watermarkSpacingY = 150;

  /// Number of watermark items
  static int watermarkCount = 30;

  /// Initialize security features
  static void initialize() {
    // Platform-specific initialization is done in conditional imports
  }
}
