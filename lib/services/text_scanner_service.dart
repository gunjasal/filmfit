import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:permission_handler/permission_handler.dart'; // https://pub.dev/packages/permission_handler
import '../models/rectangle_input.dart';
import '../utils/color_palette.dart';

class TextScannerService {
  static final TextScannerService _instance = TextScannerService._internal();
  factory TextScannerService() => _instance;
  TextScannerService._internal();

  CameraController? _controller;
  late List<CameraDescription> _cameras;
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<bool> initialize() async {
    try {
      _cameras = await availableCameras();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  Future<bool> requestCameraPermission() async {
    // iOS에서 설정에 권한 항목이 생성되도록 실제 카메라에 접근 시도
    try {
      // 먼저 카메라 초기화를 시도하여 권한 요청을 트리거
      if (_cameras.isEmpty) {
        await initialize();
      }
      
      if (_cameras.isNotEmpty) {
        // 임시로 카메라 컨트롤러를 생성하여 권한 요청 트리거
        final tempController = CameraController(
          _cameras.first,
          ResolutionPreset.low,
          enableAudio: false,
        );
        
        try {
          await tempController.initialize();
          await tempController.dispose();
        } catch (e) {
          // 권한이 없으면 여기서 에러가 발생하고, 이때 시스템 권한 요청이 트리거됨
        }
      }
    } catch (e) {
      // 카메라 접근 실패는 정상적인 경우 (권한이 없을 때)
    }
    
    // 이제 permission_handler로 상태 확인
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> openDeviceSettings() async {
    await openAppSettings();
  }

  Future<CameraController?> getCameraController() async {
    print('🔧 [FilmFit] getCameraController 시작');
    
    if (_cameras.isEmpty) {
      print('📹 [FilmFit] 카메라 디바이스 초기화 중...');
      final initialized = await initialize();
      if (!initialized) {
        print('❌ [FilmFit] 카메라 디바이스 초기화 실패');
        throw Exception('카메라 디바이스를 찾을 수 없습니다');
      }
      print('✅ [FilmFit] 카메라 디바이스 초기화 완료: ${_cameras.length}개 발견');
    }

    // 후면 카메라 선택
    final backCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );
    print('📷 [FilmFit] 선택된 카메라: ${backCamera.name}');

    _controller = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    print('🔄 [FilmFit] 카메라 컨트롤러 초기화 중...');
    // 실제 카메라 초기화 - 여기서 권한 오류가 발생할 수 있음
    await _controller!.initialize();
    print('✅ [FilmFit] 카메라 컨트롤러 초기화 완료');
    return _controller;
  }

  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final image = await _controller!.takePicture();
      return image;
    } catch (e) {
      return null;
    }
  }

  Future<List<RectangleInput>> recognizeText(String imagePath) async {
    try {
      print('🔍 [FilmFit] OCR 시작: $imagePath');
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      print('📝 [FilmFit] Raw 텍스트 인식 결과:');
      print('---START RAW TEXT---');
      print(recognizedText.text);
      print('---END RAW TEXT---');
      
      final results = _parseTextToRectangleInputs(recognizedText.text);
      print('🎯 [FilmFit] 파싱된 결과: ${results.length}개 항목');
      
      return results;
    } catch (e) {
      print('❌ [FilmFit] OCR 실패: $e');
      return [];
    }
  }

  List<RectangleInput> _parseTextToRectangleInputs(String text) {
    print('🔧 [FilmFit] 텍스트 파싱 시작');
    final List<RectangleInput> rectangleInputs = [];
    
    // 정규식: 연속된 3개의 양의 정수를 찾는 패턴
    // 구분자: 공백, x, X, *, ×, 쉼표 등 모든 비숫자 문자
    final pattern = RegExp(r'(\d+)[^\d]*(\d+)[^\d]*(\d+)');
    final matches = pattern.allMatches(text);
    
    print('🔍 [FilmFit] 정규식 매치 개수: ${matches.length}');
    
    int colorIndex = 0;
    for (final match in matches) {
      try {
        final width = int.parse(match.group(1)!);
        final height = int.parse(match.group(2)!);
        final count = int.parse(match.group(3)!);
        
        print('📏 [FilmFit] 매치 #${colorIndex + 1}: width=$width, height=$height, count=$count');
        print('   원본 매치: "${match.group(0)}"');
        
        // 양의 정수만 허용하고 실용적인 범위로 제한
        if (width > 0 && width <= 99999 && 
            height > 0 && height <= 99999 && 
            count > 0 && count <= 9999) {
          final newInput = RectangleInput(
            width: width,
            height: height,
            count: count,
            color: ColorPalette.getColor(colorIndex),
            id: 'scanned_${colorIndex}_${DateTime.now().millisecondsSinceEpoch}',
          );
          rectangleInputs.add(newInput);
          print('✅ [FilmFit] 유효한 입력으로 추가됨: ID=${newInput.id}');
          print('   세부정보: width=${newInput.width}, height=${newInput.height}, count=${newInput.count}');
          colorIndex++;
        } else {
          print('❌ [FilmFit] 범위를 벗어나서 무시됨 (w:$width, h:$height, c:$count)');
        }
      } catch (e) {
        print('❌ [FilmFit] 파싱 실패: $e');
        // 파싱 실패한 경우 무시하고 계속 진행
        continue;
      }
    }
    
    print('🎯 [FilmFit] 최종 결과: ${rectangleInputs.length}개의 유효한 사각형 입력');
    return rectangleInputs;
  }

  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
  }
}
