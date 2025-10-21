class ScreenBreakPoints {
  // Breakpoint values
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;

  // Helpers methods
  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) =>
      width >= desktop && width < largeDesktop;
  static bool isLargeDesktop(double width) => width >= largeDesktop;

  // Get the device type
  static DeviceType getDeviceType(double width) {
    if (width >= largeDesktop) return DeviceType.largeDesktop;
    if (width >= desktop) return DeviceType.desktop;
    if (width >= tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }

   // Get columns for grid layouts
  static int getColumns(double width) {
    if (isLargeDesktop(width)) return 6;
    if (isDesktop(width)) return 4;
    if (isTablet(width)) return 3;
    return 2;
  }

  // Get padding based on screen size
  static double getPadding(double width) {
    if (isLargeDesktop(width)) return 32.0;
    if (isDesktop(width)) return 24.0;
    if (isTablet(width)) return 20.0;
    return 16.0;
  }
}

enum DeviceType { mobile, tablet, desktop, largeDesktop }

extension DeviceTypeExtension on DeviceType{
  bool get isMobile => this == DeviceType.mobile;
  bool get isTablet => this == DeviceType.tablet;
  bool get isDesktop => this == DeviceType.desktop;
  bool get isLargeDesktop => this == DeviceType.largeDesktop;

  String get name {
    switch (this) {
      case DeviceType.mobile:
        return 'Mobile';
      case DeviceType.tablet:
        return 'Tablet';
      case DeviceType.desktop:
        return 'Desktop';
      case DeviceType.largeDesktop:
        return 'Large Desktop';
    }
  }
}

