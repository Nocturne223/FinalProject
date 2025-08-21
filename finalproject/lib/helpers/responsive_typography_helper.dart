import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

DeviceType getDeviceType(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width < 600) return DeviceType.mobile;
  if (width < 1200) return DeviceType.tablet;
  return DeviceType.desktop;
}

double getResponsiveFontSize(
  BuildContext context, {
  double mobile = 14,
  double tablet = 18,
  double desktop = 22,
}) {
  switch (getDeviceType(context)) {
    case DeviceType.mobile:
      return mobile;
    case DeviceType.tablet:
      return tablet;
    case DeviceType.desktop:
      return desktop;
  }
}
