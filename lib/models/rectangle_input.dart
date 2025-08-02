import 'package:flutter/material.dart';

class RectangleInput {
  int width;
  int height;
  int count;
  Color color;
  final String id;

  RectangleInput({
    this.width = 0,
    this.height = 0,
    this.count = 0,
    required this.color,
    required this.id,
  });

  bool get isValid => width > 0 && height > 0 && count > 0;

  RectangleInput copyWith({
    int? width,
    int? height,
    int? count,
    Color? color,
  }) {
    return RectangleInput(
      width: width ?? this.width,
      height: height ?? this.height,
      count: count ?? this.count,
      color: color ?? this.color,
      id: id,
    );
  }
}
