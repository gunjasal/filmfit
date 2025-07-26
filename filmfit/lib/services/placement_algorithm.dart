import 'package:flutter/material.dart';
import '../models/rectangle_input.dart';
import '../models/placed_rectangle.dart';

class PlacementAlgorithm {
  static const double boardWidth = 1220; // mm
  static const double initialBoardHeight = 50000; // mm

  static List<PlacedRectangle> placeRectangles(
    List<RectangleInput> inputs,
    bool allowRotation,
  ) {
    final List<PlacedRectangle> placedRectangles = [];
    final List<_Rectangle> rectanglesToPlace = [];

    // 배치할 사각형 리스트 생성
    for (final input in inputs) {
      for (int i = 0; i < input.count; i++) {
        rectanglesToPlace.add(_Rectangle(
          id: '${input.id}_$i',
          width: input.width.toDouble(),
          height: input.height.toDouble(),
          color: input.color,
        ));
      }
    }

    // 크기가 큰 순서로 정렬 (Bottom-Left Fill 최적화)
    rectanglesToPlace.sort((a, b) => (b.width * b.height).compareTo(a.width * a.height));

    double currentBoardHeight = initialBoardHeight;

    for (final rect in rectanglesToPlace) {
      PlacedRectangle? placed;

      if (allowRotation) {
        // 회전 허용 시 두 방향 모두 시도
        placed = _findBestPosition(placedRectangles, rect, boardWidth, currentBoardHeight) ??
            _findBestPosition(placedRectangles, rect.rotated(), boardWidth, currentBoardHeight);
      } else {
        // 회전 불허용 시 원본만 시도
        placed = _findBestPosition(placedRectangles, rect, boardWidth, currentBoardHeight);
      }

      if (placed != null) {
        placedRectangles.add(placed);
      } else {
        // 배치 실패 시 보드 높이 확장
        currentBoardHeight += 10000; // 10m씩 확장
        placed = _findBestPosition(placedRectangles, rect, boardWidth, currentBoardHeight);
        if (placed != null) {
          placedRectangles.add(placed);
        }
      }
    }

    return placedRectangles;
  }

  static PlacedRectangle? _findBestPosition(
    List<PlacedRectangle> existingRectangles,
    _Rectangle rect,
    double boardWidth,
    double boardHeight,
  ) {
    // Bottom-Left Fill 알고리즘 구현
    for (double y = 0; y <= boardHeight - rect.height; y += 1) {
      for (double x = 0; x <= boardWidth - rect.width; x += 1) {
        final candidate = PlacedRectangle(
          id: rect.id,
          x: x,
          y: y,
          width: rect.width,
          height: rect.height,
          color: rect.color,
          isRotated: rect.isRotated,
        );

        // 다른 사각형과 겹치지 않는지 확인
        bool overlaps = false;
        for (final existing in existingRectangles) {
          if (candidate.overlaps(existing)) {
            overlaps = true;
            break;
          }
        }

        if (!overlaps && !candidate.isOutOfBounds(boardWidth, boardHeight)) {
          return candidate;
        }
      }
    }

    return null;
  }

  static double calculateUsedHeight(List<PlacedRectangle> rectangles) {
    if (rectangles.isEmpty) return 0;
    
    double maxY = 0;
    for (final rect in rectangles) {
      final bottom = rect.y + rect.displayHeight;
      if (bottom > maxY) {
        maxY = bottom;
      }
    }
    return maxY;
  }
}

class _Rectangle {
  final String id;
  final double width;
  final double height;
  final Color color;
  final bool isRotated;

  _Rectangle({
    required this.id,
    required this.width,
    required this.height,
    required this.color,
    this.isRotated = false,
  });

  _Rectangle rotated() {
    return _Rectangle(
      id: id,
      width: height,
      height: width,
      color: color,
      isRotated: true,
    );
  }
}
