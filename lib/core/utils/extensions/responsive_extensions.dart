import 'package:flutter/material.dart';
import 'package:app/core/responsive/screen_break_points.dart';

extension ResponsiveDouble on double {
  /// Scale this value based on screen size
  double responsive(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = ScreenBreakPoints.getDeviceType(width);

    switch (deviceType) {
      case DeviceType.largeDesktop:
        return this * 1.4;
      case DeviceType.desktop:
        return this * 1.2;
      case DeviceType.tablet:
        return this * 1.1;
      case DeviceType.mobile:
        return this;
    }
  }

  /// Get responsive font size
  double get sp => this;

  /// Get responsive width
  double w(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (this / 100) * screenWidth;
  }

  /// Get responsive height
  double h(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (this / 100) * screenHeight;
  }
}

extension ResponsiveInt on int {
  /// Scale this value based on screen size
  double responsive(BuildContext context) {
    return toDouble().responsive(context);
  }

  /// Get responsive font size
  double get sp => toDouble();

  /// Get responsive width percentage
  double w(BuildContext context) {
    return toDouble().w(context);
  }

  /// Get responsive height percentage
  double h(BuildContext context) {
    return toDouble().h(context);
  }
}

extension ResponsiveWidget on Widget {
  /// Make widget responsive with different layouts
  Widget responsive({
    Widget? tablet,
    Widget? desktop,
    Widget? largeDesktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType =
            ScreenBreakPoints.getDeviceType(constraints.maxWidth);

        switch (deviceType) {
          case DeviceType.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? this;
          case DeviceType.desktop:
            return desktop ?? tablet ?? this;
          case DeviceType.tablet:
            return tablet ?? this;
          case DeviceType.mobile:
            return this;
        }
      },
    );
  }

  /// Add responsive padding
  Widget paddingResponsive(BuildContext context) {
    final padding =
        ScreenBreakPoints.getPadding(MediaQuery.of(context).size.width);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }

  /// Center widget on larger screens
  Widget centerOnDesktop() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType =
            ScreenBreakPoints.getDeviceType(constraints.maxWidth);

        if (deviceType.isDesktop || deviceType.isLargeDesktop) {
          return Center(child: this);
        }
        return this;
      },
    );
  }
}
