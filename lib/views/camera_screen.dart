import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/text_scanner_service.dart';
import '../models/rectangle_input.dart';

class CameraScreen extends StatefulWidget {
  final Function(List<RectangleInput>) onTextRecognized;

  const CameraScreen({
    super.key,
    required this.onTextRecognized,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isLoading = false;
  bool _isRecognizing = false;
  final TextScannerService _textScannerService = TextScannerService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    print('📷 [FilmFit] 카메라 초기화 시작');
    setState(() {
      _isLoading = true;
    });

    try {
      // iOS에서는 권한 체크보다 직접 카메라 초기화를 시도하는 것이 더 정확함
      _controller = await _textScannerService.getCameraController();
      if (_controller != null && mounted) {
        print('✅ [FilmFit] 카메라 초기화 성공');
        setState(() {
          _isLoading = false;
        });
      } else {
        print('❌ [FilmFit] 카메라 컨트롤러가 null');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog('카메라 초기화에 실패했습니다.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('🚨 [FilmFit] Camera initialization error: $e'); // 디버깅용
        
        // 에러 메시지에 따라 다른 처리
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('permission') || errorMessage.contains('권한')) {
          _showErrorDialog('카메라 권한이 필요합니다.\n설정 > 개인정보 보호 및 보안 > 카메라에서 FilmFit을 허용해주세요.');
        } else {
          _showErrorDialog('카메라 사용 중 오류가 발생했습니다: ${e.toString()}');
        }
      }
    }
  }

  Future<void> _takePictureAndRecognize() async {
    if (_controller == null || _isRecognizing) return;

    setState(() {
      _isRecognizing = true;
    });

    try {
      // 사진 촬영
      final image = await _textScannerService.takePicture();
      if (image == null) {
        throw Exception('사진 촬영에 실패했습니다');
      }

      // 텍스트 인식
      final rectangleInputs = await _textScannerService.recognizeText(image.path);
      print('📊 [FilmFit] CameraScreen에서 받은 결과: ${rectangleInputs.length}개');
      for (int i = 0; i < rectangleInputs.length; i++) {
        final input = rectangleInputs[i];
        print('   입력 #${i + 1}: ${input.width} x ${input.height} x ${input.count}');
      }

      if (mounted) {
        setState(() {
          _isRecognizing = false;
        });

        if (rectangleInputs.isEmpty) {
          print('⚠️ [FilmFit] 인식된 패턴이 없어서 snackbar 표시');
          // 패턴 미발견
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('인식할 수 있는 텍스트 패턴이 없습니다. (예: 100 x 200 x 3)'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          print('✅ [FilmFit] ${rectangleInputs.length}개 인식 성공, 콜백 호출');
          // 인식 성공
          Navigator.of(context).pop();
          widget.onTextRecognized(rectangleInputs);
        }
      }

      // 임시 이미지 파일 삭제 (이미지 저장하지 않음)
      try {
        final file = File(image.path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // 삭제 실패해도 무시
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRecognizing = false;
        });
        
        // OCR 실패
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('텍스트 인식에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
          if (message.contains('권한'))
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                await _textScannerService.openDeviceSettings();
              },
              child: const Text(
                '설정 열기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('텍스트 스캔'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _controller == null
              ? const Center(
                  child: Text(
                    '카메라를 사용할 수 없습니다',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Stack(
                  children: [
                    // 카메라 프리뷰
                    SizedBox.expand(
                      child: CameraPreview(_controller!),
                    ),
                    
                    // 인식 중 오버레이
                    if (_isRecognizing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                '텍스트 인식 중...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // 촬영 버튼
                    if (!_isRecognizing)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: GestureDetector(
                            onTap: _takePictureAndRecognize,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 4,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // 안내 텍스트
                    if (!_isRecognizing)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: 50),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '텍스트가 포함된 화면을 촬영하세요\n예: "100 x 200 x 3"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
