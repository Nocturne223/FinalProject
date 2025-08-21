import 'package:flutter/material.dart';

class ResponsiveLayoutHelper {
  static int getColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 1; // Mobile
    } else if (width < 900) {
      return 2; // Tablet
    } else {
      return 3; // Desktop
    }
  }
  
  static double getCardHeight(BuildContext context) {
    final columns = getColumnCount(context);
    switch (columns) {
      case 1:
        return 220; // Mobile
      case 2:
        return 240; // Tablet
      case 3:
        return 260; // Desktop
      default:
        return 220;
    }
  }
  
  static double getCardAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600 ? 1.1 : 1.7;
  }
  
  static EdgeInsets getCardSpacing() {
    return const EdgeInsets.all(12);
  }
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }
  
  static double getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 32.0;
    }
  }
  
  static double getVerticalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }
}
