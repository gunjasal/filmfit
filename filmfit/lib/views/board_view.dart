import 'package:flutter/material.dart';
import '../models/rectangle_input.dart';
import '../models/placed_rectangle.dart';
import '../services/placement_algorithm.dart';
import '../widgets/placed_rectangle_widget.dart';

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

    final newX = (rectangle.x + details.delta.dx / _scale).clamp(0.0, _boardWidth - rectangle.displayWidth);
    final newY = (rectangle.y + details.delta.dy / _scale).clamp(0.0, _boardHeight - rectangle.displayHeight);

    setState(() {
      _draggingRectangle = _draggingRectangle!.copyWith(x: newX, y: newY);
      
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
      
      _draggingRectangle = null;
      _dragStartPosition = null;
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
                    // 50000mm 선 표시 (빨간 점선)
                    if (_boardHeight > PlacementAlgorithm.initialBoardHeight)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: PlacementAlgorithm.initialBoardHeight * _scale,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.red,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
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
