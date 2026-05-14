import 'package:flutter/material.dart';

class ShareImageCardConfig {
  const ShareImageCardConfig._();

  static const double width = 540;
  static const double height = 800;
  static const Size size = Size(width, height);

  static const double previewCornerRadius = 22;
  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(22, 16, 22, 16);
  static const EdgeInsets overlaySafePadding = EdgeInsets.fromLTRB(
    width * 0.14,
    height * 0.26,
    width * 0.14,
    height * 0.34,
  );

  static const double topScrimHeight = height * 0.20;
  static const double bottomScrimHeight = height * 0.28;
}
