/// A centralized class for managing design system constants like spacing, padding,
/// border radii, and component sizes. Using a consistent scale (e.g., 8-point system)
/// ensures a harmonious and professional-looking UI.
class AppDimensions {
  AppDimensions._();

  // --- PADDING ---
  // Use for wrapping content inside containers or for page-level padding.
  static const double paddingSmall = 8.0; // For tight spaces
  static const double paddingMedium = 16.0; // Default page/card padding
  static const double paddingLarge = 24.0; // For larger section padding
  static const double paddingXLarge = 32.0; // For significant separation

  // --- SPACING ---
  // Use for SizedBoxes between elements in a Column or Row.
  static const double spacingXXSmall = 4.0;
  static const double spacingXSmall = 8.0;
  static const double spacingSmall = 12.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // --- BORDER RADIUS ---
  // A consistent radius scale for cards, buttons, inputs, etc.
  static const double borderRadiusSmall = 8.0; // For smaller elements like tags
  static const double borderRadiusMedium = 12.0; // For buttons and inputs
  static const double borderRadiusLarge = 16.0; // For standard cards
  static const double borderRadiusXLarge = 24.0; // For larger panels or dialogs

  // --- SIZING ---
  // Standard sizes for icons, avatars, and other components.
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0; // Default icon size
  static const double iconSizeLarge = 36.0;
  static const double iconSizeXLarge = 80.0; // For large display icons like in empty states

  static const double avatarRadiusMedium = 22.0;
  static const double defaultButtonHeight = 48.0;

  // --- FONT SIZES ---
  // It's often best to let the theme handle font sizes, but if you need
  // specific overrides, define them here.
  static const double defaultButtonFontSize = 16.0;

  static const double defaultScreenWidth = 500.0;
  static const double defaultBottomSheetWidth = 450.0;
  static const double defaultMargin = 20.0;
  static const double defaultPageHorizontalPadding = paddingMedium;
  static const double defaultRowPadding = spacingSmall;

  static const double borderRadiusButton = borderRadiusXLarge;
  static const double borderRadiusInput = borderRadiusSmall;

  static const double spacingVertical = 12.0;
  static const double borderRadiusSheet = 24.0;
  static const double borderRadiusListItem = 12.0;
  static const double handleWidth = 40.0;
  static const double handleHeight = 5.0;
  static const double handleBorderRadius = 10.0;
  static const double headerFontSize = 18.0;
  static const double listItemFontSize = 16.0;
  static const double buttonHeight = 48.0;

// --- DEPRECATED/REMOVED ---
// static const double defaultScreenWidth = 400.0;
// Note: Hardcoding screen width is an anti-pattern. It's better to build
// responsive layouts that adapt to the actual screen size.

// The following are renamed for clarity and consistency with the new system.
// static const double defaultMargin = 20.0; -> Use padding/spacing constants
// static const double defaultPageHorizontalPadding = 16.0; -> Use paddingMedium
// static const double defaultRowPadding = 10.0; -> Use spacingSmall or Medium
}
