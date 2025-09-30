import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _prefBrightness = 'brightness';
  static const _prefGrainOpacity = 'grain_opacity';

  Brightness _brightness = Brightness.light;
  double _grainOpacity = 0.03; // default subtle texture

  Brightness get brightness => _brightness;
  double get grainOpacity => _grainOpacity;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final brightnessIndex = prefs.getInt(_prefBrightness);
    if (brightnessIndex != null &&
        brightnessIndex >= 0 &&
        brightnessIndex <= 1) {
      _brightness = Brightness.values[brightnessIndex];
    }
    _grainOpacity = prefs.getDouble(_prefGrainOpacity) ?? _grainOpacity;
    notifyListeners();
  }

  Future<void> setBrightness(Brightness brightness) async {
    _brightness = brightness;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefBrightness, brightness.index);
  }

  void toggleTheme() {
    _brightness =
        _brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_prefBrightness, _brightness.index);
    });
  }

  Future<void> setGrainOpacity(double opacity) async {
    _grainOpacity = opacity.clamp(0.0, 0.15);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefGrainOpacity, _grainOpacity);
  }
}
