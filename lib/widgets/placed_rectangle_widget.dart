import 'package:flutter/material.dart';
import '../models/placed_rectangle.dart';

class PlacedRectangleWidget extends StatelessWidget {
  final PlacedRectangle rectangle;
  final double scale;
  final VoidCallback? onTap;
  final Function(DragUpdateDetails)? onPanUpdate;
  final Function(DragStartDetails)? onPanStart;
  final Function(DragEndDetails)? onPanEnd;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const PlacedRectangleWidget({
    Key? key,
    required this.rectangle,
    required this.scale,
    this.onTap,
    this.onPanUpdate,
    this.onPanStart,
    this.onPanEnd,
    this.onLongPressStart,
    this.onLongPressEnd,
  }) : super(key: key);

  String _getSizeText() {
    if (rectangle.isRotated) {
      return '${rectangle.height.toInt()}×${rectangle.width.toInt()}mm';
    } else {
      return '${rectangle.width.toInt()}×${rectangle.height.toInt()}mm';
    }
  }

  double _getFontSize() {
    final minDimension = rectangle.displayWidth < rectangle.displayHeight
        ? rectangle.displayWidth * scale
        : rectangle.displayHeight * scale;
    
    if (minDimension < 30) return 8;
    if (minDimension < 50) return 10;
    if (minDimension < 80) return 12;
    return 14;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: rectangle.x * scale,
      top: rectangle.y * scale,
      width: rectangle.displayWidth * scale,
      height: rectangle.displayHeight * scale,
      child: GestureDetector(
        onTap: onTap,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onLongPressStart: (_) => onLongPressStart?.call(),
        onLongPressEnd: (_) => onLongPressEnd?.call(),
        child: Container(
          decoration: BoxDecoration(
            color: rectangle.displayColor,
            border: Border.all(
              color: rectangle.borderColor,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // 크기 정보 표시
              Center(
                child: Text(
                  _getSizeText(),
                  style: TextStyle(
                    fontSize: _getFontSize(),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // 회전 인디케이터
              if (rectangle.isRotated)
                Positioned(
                  left: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '↻',
                      style: TextStyle(
                        fontSize: _getFontSize() * 0.8,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
