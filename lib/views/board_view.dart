import 'package:flutter/material.dart';
import '../models/rectangle_input.dart';
import '../models/placed_rectangle.dart';
import '../services/placement_algorithm.dart';
import '../services/snapping_service.dart';
import '../widgets/placed_rectangle_widget.dart';

// 점선을 그리는 CustomPainter
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final String? text;
  final bool showTextBelow;

  DashedLinePainter({
    required this.color,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.text,
    this.showTextBelow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 점선 그리기
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 1),
        Offset(startX + dashWidth, 1),
        linePaint,
      );
      startX += dashWidth + dashSpace;
    }

    // 텍스트 그리기 (있는 경우)
    if (text != null && text!.isNotEmpty) {
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );
      final textSpan = TextSpan(
        text: text,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // 배경 박스 그리기
      final textWidth = textPainter.width + 12; // 패딩 포함
      final textHeight = textPainter.height + 6; // 패딩 포함
      final textX = 8.0;
      final textY = showTextBelow ? 8.0 : -textHeight + 2;

      final backgroundPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      final backgroundRect = RRect.fromLTRBR(
        textX, textY, textX + textWidth, textY + textHeight, 
        const Radius.circular(4)
      );
      canvas.drawRRect(backgroundRect, backgroundPaint);

      // 텍스트 그리기
      textPainter.paint(canvas, Offset(textX + 6, textY + 3));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BoardView extends StatefulWidget {
  final List<RectangleInput> rectangleInputs;
  final bool allowRotation;
  final VoidCallback onBack;

  const BoardView({
    Key? key,
    required this.rectangleInputs,
    required this.allowRotation,
    required this.onBack,
  }) : super(key: key);

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  List<PlacedRectangle> _placedRectangles = [];
  double _boardHeight = PlacementAlgorithm.initialBoardHeight;
  double _usedHeight = 0;
  PlacedRectangle? _draggingRectangle;
  Offset? _dragStartPosition;
  
  // 스내핑 관련 상태
  bool _isSnapped = false;
  SnapPoint? _currentSnapPoint;

  static const double _boardWidth = PlacementAlgorithm.boardWidth;

  @override
  void initState() {
    super.initState();
    _placeRectangles();
  }

  void _placeRectangles() {
    final placed = PlacementAlgorithm.placeRectangles(
      widget.rectangleInputs,
      widget.allowRotation,
    );
    
    setState(() {
      _placedRectangles = placed;
      _usedHeight = PlacementAlgorithm.calculateUsedHeight(placed);
      
      // 필요하면 보드 높이 확장
      if (_usedHeight > _boardHeight) {
        _boardHeight = _usedHeight + 1000; // 여유 공간 추가
      }
    });
  }

  double get _scale {
    final screenWidth = MediaQuery.of(context).size.width - 32; // 패딩 고려
    return screenWidth / _boardWidth;
  }

  void _onRectangleTap(PlacedRectangle rectangle) {
    if (_draggingRectangle != null) return; // 드래그 중이면 무시

    // 회전 시도
    final rotated = rectangle.copyWith(isRotated: !rectangle.isRotated);
    
    // 회전 후 충돌 검사
    bool canRotate = true;
    String? errorMessage;

    // Board 경계 검사
    if (rotated.isOutOfBounds(_boardWidth, _boardHeight)) {
      canRotate = false;
      errorMessage = '회전 시 Board 영역을 벗어납니다.';
    }

    // 다른 사각형과의 충돌 검사
    if (canRotate) {
      for (final other in _placedRectangles) {
        if (other.id != rectangle.id && rotated.overlaps(other)) {
          canRotate = false;
          errorMessage = '회전 시 다른 사각형과 겹칩니다.';
          break;
        }
      }
    }

    if (canRotate) {
      setState(() {
        final index = _placedRectangles.indexWhere((r) => r.id == rectangle.id);
        if (index != -1) {
          _placedRectangles[index] = rotated;
          _usedHeight = PlacementAlgorithm.calculateUsedHeight(_placedRectangles);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? '회전할 수 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onPanStart(PlacedRectangle rectangle, DragStartDetails details) {
    setState(() {
      _draggingRectangle = rectangle.copyWith(isDragging: true);
      _dragStartPosition = Offset(rectangle.x, rectangle.y);
      
      final index = _placedRectangles.indexWhere((r) => r.id == rectangle.id);
      if (index != -1) {
        _placedRectangles[index] = _draggingRectangle!;
      }
    });
  }

  void _onPanUpdate(PlacedRectangle rectangle, DragUpdateDetails details) {
    if (_draggingRectangle == null) return;

    // 기본 새 위치 계산
    final newX = (rectangle.x + details.delta.dx / _scale).clamp(0.0, _boardWidth - rectangle.displayWidth);
    final newY = (rectangle.y + details.delta.dy / _scale).clamp(0.0, _boardHeight - rectangle.displayHeight);

    // 임시 사각형으로 스내핑 계산
    final tempRectangle = _draggingRectangle!.copyWith(x: newX, y: newY);
    
    // 스내핑 계산
    final snapResult = SnappingService.calculateSnapping(
      tempRectangle,
      _placedRectangles,
      _boardWidth,
      _boardHeight,
      _scale,
    );

    setState(() {
      // 스내핑된 위치 또는 원래 위치 사용
      _draggingRectangle = _draggingRectangle!.copyWith(
        x: snapResult.x.clamp(0.0, _boardWidth - rectangle.displayWidth),
        y: snapResult.y.clamp(0.0, _boardHeight - rectangle.displayHeight),
      );
      
      // 스내핑 상태 업데이트
      _isSnapped = snapResult.isSnapped;
      _currentSnapPoint = snapResult.snapPoint;
      
      final index = _placedRectangles.indexWhere((r) => r.id == rectangle.id);
      if (index != -1) {
        _placedRectangles[index] = _draggingRectangle!;
      }
    });
  }

  void _onPanEnd(PlacedRectangle rectangle, DragEndDetails details) {
    if (_draggingRectangle == null) return;

    // 충돌 검사
    bool canPlace = true;
    String? errorMessage;

    // Board 경계 검사
    if (_draggingRectangle!.isOutOfBounds(_boardWidth, _boardHeight)) {
      canPlace = false;
      errorMessage = '이동 시 Board 영역을 벗어납니다.';
    }

    // 다른 사각형과의 충돌 검사
    if (canPlace) {
      for (final other in _placedRectangles) {
        if (other.id != _draggingRectangle!.id && _draggingRectangle!.overlaps(other)) {
          canPlace = false;
          errorMessage = '이동 시 다른 사각형과 겹칩니다.';
          break;
        }
      }
    }

    setState(() {
      final index = _placedRectangles.indexWhere((r) => r.id == rectangle.id);
      if (index != -1) {
        if (canPlace) {
          // 성공적으로 배치
          _placedRectangles[index] = _draggingRectangle!.copyWith(isDragging: false);
          _usedHeight = PlacementAlgorithm.calculateUsedHeight(_placedRectangles);
        } else {
          // 원래 위치로 복원
          _placedRectangles[index] = rectangle.copyWith(
            x: _dragStartPosition!.dx,
            y: _dragStartPosition!.dy,
            isDragging: false,
          );
          
          // 에러 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage ?? '이동할 수 없습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
      // 스내핑 상태 초기화
      _draggingRectangle = null;
      _dragStartPosition = null;
      _isSnapped = false;
      _currentSnapPoint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayHeight = _boardHeight * _scale;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('FilmFit - 배치 결과'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: widget.onBack,
            child: const Text(
              '다시 입력하기',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // UsedHeight 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Text(
              '${_usedHeight.toInt()}mm / ${PlacementAlgorithm.initialBoardHeight.toInt()}mm',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Board
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                height: displayHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Stack(
                  children: [
                    // 50000mm 선 표시 (빨간 실선)
                    if (_boardHeight > PlacementAlgorithm.initialBoardHeight)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: PlacementAlgorithm.initialBoardHeight * _scale,
                        child: CustomPaint(
                          size: const Size(double.infinity, 2),
                          painter: DashedLinePainter(
                            color: Colors.red,
                            dashWidth: double.infinity, // 실선 효과
                            dashSpace: 0,
                            text: '${PlacementAlgorithm.initialBoardHeight.toInt()}mm (Original Limit)',
                            showTextBelow: false,
                          ),
                        ),
                      ),
                    
                    // 실제 사용된 높이 라인 (파란 점선)
                    if (_placedRectangles.isNotEmpty && _usedHeight > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: _usedHeight * _scale,
                        child: CustomPaint(
                          size: const Size(double.infinity, 2),
                          painter: DashedLinePainter(
                            color: Colors.blue,
                            text: 'Used: ${_usedHeight.toInt()}mm',
                            showTextBelow: true,
                          ),
                        ),
                      ),
                    
                    // 배치된 사각형들
                    ..._placedRectangles.map((rectangle) {
                      return PlacedRectangleWidget(
                        rectangle: rectangle,
                        scale: _scale,
                        onTap: () => _onRectangleTap(rectangle),
                        onPanStart: (details) => _onPanStart(rectangle, details),
                        onPanUpdate: (details) => _onPanUpdate(rectangle, details),
                        onPanEnd: (details) => _onPanEnd(rectangle, details),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
