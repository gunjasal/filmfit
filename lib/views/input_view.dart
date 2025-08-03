import 'package:flutter/material.dart';
import '../models/rectangle_input.dart';
import '../utils/color_palette.dart';
import '../widgets/rectangle_input_list.dart';
import '../services/text_scanner_service.dart';
import 'board_view.dart';
import 'camera_screen.dart';

class InputView extends StatefulWidget {
  const InputView({Key? key}) : super(key: key);

  @override
  State<InputView> createState() => _InputViewState();
}

class _InputViewState extends State<InputView> {
  List<RectangleInput> _rectangleInputs = [];
  bool _allowRotation = true;
  final TextScannerService _textScannerService = TextScannerService();

  @override
  void initState() {
    super.initState();
    // 초기 RectangleInput 하나 생성
    _rectangleInputs = [
      RectangleInput(
        color: ColorPalette.getColor(0),
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    ];
  }

  bool get _canPlace {
    return _rectangleInputs.any((input) => input.isValid);
  }

  void _navigateToBoard() {
    // 유효한 입력만 필터링
    final validInputs = _rectangleInputs.where((input) => input.isValid).toList();
    
    if (validInputs.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BoardView(
            rectangleInputs: validInputs,
            allowRotation: _allowRotation,
            onBack: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
  }

  Future<void> _openTextScanner() async {
    try {
      // 먼저 TextScannerService 초기화
      await _textScannerService.initialize();
      
      // iOS에서는 실제 카메라 접근을 시도하는 것이 더 정확함
      print('🔍 [FilmFit] 카메라 스캐너 시작 시도');
      _launchCamera();
      
    } catch (e) {
      print('🚨 [FilmFit] 텍스트 스캐너 오류: $e');
      // 초기화 실패시 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카메라 초기화에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _launchCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          onTextRecognized: (recognizedInputs) {
            print('🎯 [FilmFit] InputView에서 콜백 받음: ${recognizedInputs.length}개');
            for (int i = 0; i < recognizedInputs.length; i++) {
              final input = recognizedInputs[i];
              print('   콜백 입력 #${i + 1}: ${input.width} x ${input.height} x ${input.count}');
            }
            
            setState(() {
              // 기존 입력들 삭제하고 새로운 입력들로 교체
              _rectangleInputs = recognizedInputs;
            });
            
            print('✅ [FilmFit] 상태 업데이트 완료, UI 갱신됨');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${recognizedInputs.length}개의 항목이 인식되었습니다'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FilmFit - 사각형 입력'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 회전 허용 체크박스
            Row(
              children: [
                Checkbox(
                  value: !_allowRotation,
                  onChanged: (value) {
                    setState(() {
                      _allowRotation = !(value ?? false);
                    });
                  },
                ),
                const Text('사각형 회전 허용안함'),
              ],
            ),
            const SizedBox(height: 16),
            
            // RectangleInputList
            Expanded(
              child: RectangleInputList(
                rectangleInputs: _rectangleInputs,
                onChanged: (updatedInputs) {
                  setState(() {
                    _rectangleInputs = updatedInputs;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 배치 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canPlace ? _navigateToBoard : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  '배치',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      // TextScanner FloatingActionButton
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: _openTextScanner,
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
