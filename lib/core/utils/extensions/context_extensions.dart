import 'package:flutter/material.dart';
import 'package:app/core/responsive/screen_break_points.dart';

extension ContextExtensions on BuildContext {
  // Screen size getters
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  // Device type getters
  DeviceType get deviceType => ScreenBreakPoints.getDeviceType(screenWidth);
  bool get isMobile => deviceType.isMobile;
  bool get isTablet => deviceType.isTablet;
  bool get isDesktop => deviceType.isDesktop;
  bool get isLargeDesktop => deviceType.isLargeDesktop;

  // Responsive values
  double get responsivePadding => ScreenBreakPoints.getPadding(screenWidth);
  int get responsiveColumns => ScreenBreakPoints.getColumns(screenWidth);

  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // Navigation shortcuts
  NavigatorState get navigator => Navigator.of(this);
  void pop<T>([T? result]) => navigator.pop(result);
  Future<T?> push<T>(Route<T> route) => navigator.push(route);
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      navigator.pushNamed(routeName, arguments: arguments);

  // Scaffold messenger shortcuts
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
  void showSnackBar(SnackBar snackBar) =>
      scaffoldMessenger.showSnackBar(snackBar);

  // Focus shortcuts
  FocusScopeNode get focusScope => FocusScope.of(this);
  void unfocus() => focusScope.unfocus();

  // Orientation
  Orientation get orientation => MediaQuery.of(this).orientation;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  // Safe area
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  double get statusBarHeight => padding.top;
  double get bottomPadding => padding.bottom;
}
