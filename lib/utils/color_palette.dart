import 'package:flutter/material.dart';

class ColorPalette {
  static const List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.black,
    Colors.white,
    Colors.grey,
    Colors.cyan,
    Colors.teal,
    Color(0xFF4CAF50), // Lime
    Color(0xFF000080), // Navy
    Color(0xFF008080), // Teal
    Color(0xFF800000), // Maroon
    Color(0xFF808000), // Olive
    Color(0xFFFFD700), // Gold
    Color(0xFFC0C0C0), // Silver
    Color(0xFF4B0082), // Indigo
    Color(0xFFFF7F50), // Coral
    Color(0xFF40E0D0), // Turquoise
    Color(0xFFF5F5DC), // Beige
    Color(0xFF98FB98), // Mint
    Color(0xFFE6E6FA), // Lavender
    Color(0xFFFFDAB9), // Peach
    Color(0xFF87CEEB), // Sky Blue
    Color(0xFFDC143C), // Crimson
    Color(0xFF7FFF00), // Chartreuse
  ];

  static Color getColor(int index) {
    return colors[index % colors.length];
  }

  static int get length => colors.length;
}
