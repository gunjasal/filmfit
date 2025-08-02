import 'package:flutter/material.dart';

class PlacedRectangle {
  final String id;
  double x;
  double y;
  double width;
  double height;
  final Color color;
  bool isRotated;
  bool isDragging;

  PlacedRectangle({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
    this.isRotated = false,
    this.isDragging = false,
  });

  // 회전된 크기 반환
  double get displayWidth => isRotated ? height : width;
  double get displayHeight => isRotated ? width : height;

  // 테두리 색상 (80% 어둡게)
  Color get borderColor {
    return Color.fromRGBO(
      (color.r * 0.8).round(),
      (color.g * 0.8).round(),
      (color.b * 0.8).round(),
      1.0,
    );
  }

  // 드래그 중일 때 색상 (opacity 0.7)
  Color get displayColor => isDragging ? color.withValues(alpha: 0.7) : color;

  Rect get rect => Rect.fromLTWH(x, y, displayWidth, displayHeight);

  PlacedRectangle copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    bool? isRotated,
    bool? isDragging,
  }) {
    return PlacedRectangle(
      id: id,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color,
      isRotated: isRotated ?? this.isRotated,
      isDragging: isDragging ?? this.isDragging,
    );
  }

  // 다른 사각형과 겹치는지 확인
  bool overlaps(PlacedRectangle other) {
    return rect.overlaps(other.rect);
  }

  // Board 영역을 벗어나는지 확인
  bool isOutOfBounds(double boardWidth, double boardHeight) {
    return x < 0 || y < 0 || x + displayWidth > boardWidth || y + displayHeight > boardHeight;
  }
}
