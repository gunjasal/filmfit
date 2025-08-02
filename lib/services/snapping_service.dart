import 'dart:math';
import '../models/placed_rectangle.dart';

/// 스내핑 포인트 타입
enum SnapPointType {
  corner,  // 꼭지점
  edge,    // 모서리
}

/// 스내핑 포인트 정보
class SnapPoint {
  final double x;
  final double y;
  final SnapPointType type;
  final String? rectangleId; // null이면 Board 경계

  SnapPoint({
    required this.x,
    required this.y,
    required this.type,
    this.rectangleId,
  });
}

/// 스내핑 결과
class SnapResult {
  final double x;
  final double y;
  final bool isSnapped;
  final SnapPoint? snapPoint;

  SnapResult({
    required this.x,
    required this.y,
    required this.isSnapped,
    this.snapPoint,
  });
}

/// 스내핑 서비스
class SnappingService {
  static const double snapThreshold = 20.0; // px 단위
  
  /// 점이 선분에 가장 가까운 점을 찾기
  static double _closestPointOnLineSegment(double px, double py, double x1, double y1, double x2, double y2) {
    final A = px - x1;
    final B = py - y1;
    final C = x2 - x1;
    final D = y2 - y1;
    
    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    
    if (lenSq == 0) return sqrt(A * A + B * B); // 점이면 그냥 거리
    
    final param = dot / lenSq;
    
    double xx, yy;
    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }
    
    final dx = px - xx;
    final dy = py - yy;
    return sqrt(dx * dx + dy * dy);
  }
  
  /// 점이 직사각형의 가장 가까운 모서리까지의 거리와 스내핑 포인트를 계산
  static SnapResult? _calculateEdgeSnapping(
    double px, double py,
    double rectX, double rectY, double rectWidth, double rectHeight,
    String? rectangleId, double threshold
  ) {
    final left = rectX;
    final right = rectX + rectWidth;
    final top = rectY;
    final bottom = rectY + rectHeight;
    
    // 각 모서리까지의 거리 계산
    final distances = <double, SnapPoint>{};
    
    // 상단 모서리
    if (py <= top) {
      final dist = _closestPointOnLineSegment(px, py, left, top, right, top);
      if (dist <= threshold) {
        final clampedX = px.clamp(left, right);
        distances[dist] = SnapPoint(x: clampedX, y: top, type: SnapPointType.edge, rectangleId: rectangleId);
      }
    }
    
    // 하단 모서리
    if (py >= bottom) {
      final dist = _closestPointOnLineSegment(px, py, left, bottom, right, bottom);
      if (dist <= threshold) {
        final clampedX = px.clamp(left, right);
        distances[dist] = SnapPoint(x: clampedX, y: bottom, type: SnapPointType.edge, rectangleId: rectangleId);
      }
    }
    
    // 좌측 모서리
    if (px <= left) {
      final dist = _closestPointOnLineSegment(px, py, left, top, left, bottom);
      if (dist <= threshold) {
        final clampedY = py.clamp(top, bottom);
        distances[dist] = SnapPoint(x: left, y: clampedY, type: SnapPointType.edge, rectangleId: rectangleId);
      }
    }
    
    // 우측 모서리
    if (px >= right) {
      final dist = _closestPointOnLineSegment(px, py, right, top, right, bottom);
      if (dist <= threshold) {
        final clampedY = py.clamp(top, bottom);
        distances[dist] = SnapPoint(x: right, y: clampedY, type: SnapPointType.edge, rectangleId: rectangleId);
      }
    }
    
    if (distances.isNotEmpty) {
      final minDistance = distances.keys.reduce((a, b) => a < b ? a : b);
      final snapPoint = distances[minDistance]!;
      return SnapResult(x: snapPoint.x, y: snapPoint.y, isSnapped: true, snapPoint: snapPoint);
    }
    
    return null;
  }
  
  /// 모든 스내핑 포인트를 생성 (꼭지점만)
  static List<SnapPoint> generateSnapPoints(
    List<PlacedRectangle> rectangles,
    double boardWidth,
    double boardHeight,
    String? excludeRectangleId,
  ) {
    final points = <SnapPoint>[];
    
    // Board 경계의 꼭지점들만
    points.addAll([
      SnapPoint(x: 0, y: 0, type: SnapPointType.corner),
      SnapPoint(x: boardWidth, y: 0, type: SnapPointType.corner),
      SnapPoint(x: 0, y: boardHeight, type: SnapPointType.corner),
      SnapPoint(x: boardWidth, y: boardHeight, type: SnapPointType.corner),
    ]);
    
    // 각 사각형의 꼭지점들만
    for (final rect in rectangles) {
      if (rect.id == excludeRectangleId) continue;
      
      final left = rect.x;
      final right = rect.x + rect.displayWidth;
      final top = rect.y;
      final bottom = rect.y + rect.displayHeight;
      
      // 꼭지점들
      points.addAll([
        SnapPoint(x: left, y: top, type: SnapPointType.corner, rectangleId: rect.id),
        SnapPoint(x: right, y: top, type: SnapPointType.corner, rectangleId: rect.id),
        SnapPoint(x: left, y: bottom, type: SnapPointType.corner, rectangleId: rect.id),
        SnapPoint(x: right, y: bottom, type: SnapPointType.corner, rectangleId: rect.id),
      ]);
    }
    
    return points;
  }
  
  /// 드래그하는 사각형의 스내핑 포인트들을 생성 (꼭지점만)
  static List<SnapPoint> generateDraggingRectangleSnapPoints(PlacedRectangle rectangle) {
    final left = rectangle.x;
    final right = rectangle.x + rectangle.displayWidth;
    final top = rectangle.y;
    final bottom = rectangle.y + rectangle.displayHeight;
    
    return [
      // 꼭지점들만
      SnapPoint(x: left, y: top, type: SnapPointType.corner, rectangleId: rectangle.id),
      SnapPoint(x: right, y: top, type: SnapPointType.corner, rectangleId: rectangle.id),
      SnapPoint(x: left, y: bottom, type: SnapPointType.corner, rectangleId: rectangle.id),
      SnapPoint(x: right, y: bottom, type: SnapPointType.corner, rectangleId: rectangle.id),
    ];
  }
  
  /// 스내핑 계산
  static SnapResult calculateSnapping(
    PlacedRectangle draggingRectangle,
    List<PlacedRectangle> allRectangles,
    double boardWidth,
    double boardHeight,
    double scale,
  ) {
    final snapThresholdInMM = snapThreshold / scale;
    
    SnapResult? bestResult;
    double bestDistance = double.infinity;
    
    // 드래그하는 사각형의 꼭지점들
    final draggingPoints = generateDraggingRectangleSnapPoints(draggingRectangle);
    
    // 1. 꼭지점 스내핑 (최우선)
    final targetPoints = generateSnapPoints(
      allRectangles,
      boardWidth,
      boardHeight,
      draggingRectangle.id,
    );
    
    for (final draggingPoint in draggingPoints) {
      for (final targetPoint in targetPoints) {
        final distance = sqrt(
          pow(draggingPoint.x - targetPoint.x, 2) + 
          pow(draggingPoint.y - targetPoint.y, 2)
        );
        
        if (distance <= snapThresholdInMM && distance < bestDistance) {
          final deltaX = targetPoint.x - draggingPoint.x;
          final deltaY = targetPoint.y - draggingPoint.y;
          
          bestResult = SnapResult(
            x: draggingRectangle.x + deltaX,
            y: draggingRectangle.y + deltaY,
            isSnapped: true,
            snapPoint: targetPoint,
          );
          bestDistance = distance;
        }
      }
    }
    
    // 2. 모서리 스내핑 (꼭지점 스내핑이 없을 때만)
    if (bestResult == null) {
      // Board 모서리 스내핑
      for (final draggingPoint in draggingPoints) {
        final edgeResult = _calculateEdgeSnapping(
          draggingPoint.x, draggingPoint.y,
          0, 0, boardWidth, boardHeight,
          null, snapThresholdInMM
        );
        
        if (edgeResult != null) {
          final deltaX = edgeResult.x - draggingPoint.x;
          final deltaY = edgeResult.y - draggingPoint.y;
          final distance = sqrt(deltaX * deltaX + deltaY * deltaY);
          
          if (distance < bestDistance) {
            bestResult = SnapResult(
              x: draggingRectangle.x + deltaX,
              y: draggingRectangle.y + deltaY,
              isSnapped: true,
              snapPoint: edgeResult.snapPoint,
            );
            bestDistance = distance;
          }
        }
      }
      
      // 다른 사각형 모서리 스내핑
      for (final rect in allRectangles) {
        if (rect.id == draggingRectangle.id) continue;
        
        for (final draggingPoint in draggingPoints) {
          final edgeResult = _calculateEdgeSnapping(
            draggingPoint.x, draggingPoint.y,
            rect.x, rect.y, rect.displayWidth, rect.displayHeight,
            rect.id, snapThresholdInMM
          );
          
          if (edgeResult != null) {
            final deltaX = edgeResult.x - draggingPoint.x;
            final deltaY = edgeResult.y - draggingPoint.y;
            final distance = sqrt(deltaX * deltaX + deltaY * deltaY);
            
            if (distance < bestDistance) {
              bestResult = SnapResult(
                x: draggingRectangle.x + deltaX,
                y: draggingRectangle.y + deltaY,
                isSnapped: true,
                snapPoint: edgeResult.snapPoint,
              );
              bestDistance = distance;
            }
          }
        }
      }
    }
    
    // 스내핑되지 않음
    return bestResult ?? SnapResult(
      x: draggingRectangle.x,
      y: draggingRectangle.y,
      isSnapped: false,
    );
  }
}
