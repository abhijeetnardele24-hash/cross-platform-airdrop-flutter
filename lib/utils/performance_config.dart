import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Performance optimization utilities
class PerformanceConfig {
  /// Enable performance overlay in debug mode
  static bool get showPerformanceOverlay => kDebugMode && false;
  
  /// Enable repaint rainbow in debug mode
  static bool get debugRepaintRainbow => kDebugMode && false;
  
  /// Configure rendering performance
  static void configurePerformance() {
    // Disable unnecessary checks in release mode
    if (kReleaseMode) {
      debugPaintSizeEnabled = false;
      debugPaintBaselinesEnabled = false;
      debugPaintPointersEnabled = false;
      debugPaintLayerBordersEnabled = false;
      debugRepaintRainbowEnabled = false;
    }
  }
  
  /// Optimize image cache
  static void optimizeImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
  }
}
