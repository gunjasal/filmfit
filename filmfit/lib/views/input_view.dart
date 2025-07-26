import 'package:flutter/material.dart';
import '../models/rectangle_input.dart';
import '../utils/color_palette.dart';
import '../widgets/rectangle_input_list.dart';
import 'board_view.dart';

class InputView extends StatefulWidget {
  const InputView({Key? key}) : super(key: key);

  @override
  State<InputView> createState() => _InputViewState();
}

class _InputViewState extends State<InputView> {
  List<RectangleInput> _rectangleInputs = [];
  bool _allowRotation = true;

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
    );
  }
}
