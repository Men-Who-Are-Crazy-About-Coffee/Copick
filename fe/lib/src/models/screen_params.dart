import 'dart:math';
import 'dart:ui';

class ScreenParams {
  static late Size screenSize;
  static late Size previewSize;

  static double previewRatio = max(previewSize.height, previewSize.width) /
      min(previewSize.height, previewSize.width);

  static Size screenPreviewSize =
      Size(screenSize.width, screenSize.width * previewRatio);
}
