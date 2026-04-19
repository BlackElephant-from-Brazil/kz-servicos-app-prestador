import 'package:flutter/services.dart' show rootBundle;

abstract final class MapStyles {
  static const String standard = '[]';

  static Future<String> loadLight() {
    return rootBundle.loadString('assets/map_style.json');
  }
}
