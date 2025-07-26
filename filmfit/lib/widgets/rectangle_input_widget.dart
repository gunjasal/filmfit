import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/rectangle_input.dart';

class RectangleInputWidget extends StatefulWidget {
  final RectangleInput rectangleInput;
  final VoidCallback onRemove;
  final Function(RectangleInput) onChanged;

  const RectangleInputWidget({
    Key? key,
    required this.rectangleInput,
    required this.onRemove,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<RectangleInputWidget> createState() => _RectangleInputWidgetState();
}

class _RectangleInputWidgetState extends State<RectangleInputWidget> {
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _countController;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(
      text: widget.rectangleInput.width == 0 ? '' : widget.rectangleInput.width.toString(),
    );
    _heightController = TextEditingController(
      text: widget.rectangleInput.height == 0 ? '' : widget.rectangleInput.height.toString(),
    );
    _countController = TextEditingController(
      text: widget.rectangleInput.count == 0 ? '' : widget.rectangleInput.count.toString(),
    );
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _updateInput() {
    final width = int.tryParse(_widthController.text) ?? 0;
    final height = int.tryParse(_heightController.text) ?? 0;
    final count = int.tryParse(_countController.text) ?? 0;

    widget.onChanged(widget.rectangleInput.copyWith(
      width: width,
      height: height,
      count: count,
    ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isError,
  }) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.blue,
            ),
          ),
        ),
        onTap: () {
          // 전체 텍스트 선택
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
        onChanged: (_) => _updateInput(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 색상 인디케이터
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: widget.rectangleInput.color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            
            // Width 입력
            _buildTextField(
              controller: _widthController,
              label: '가로(mm)',
              isError: widget.rectangleInput.width == 0,
            ),
            const SizedBox(width: 8),
            
            // Height 입력
            _buildTextField(
              controller: _heightController,
              label: '세로(mm)',
              isError: widget.rectangleInput.height == 0,
            ),
            const SizedBox(width: 8),
            
            // Count 입력
            _buildTextField(
              controller: _countController,
              label: '갯수',
              isError: widget.rectangleInput.count == 0,
            ),
            const SizedBox(width: 8),
            
            // 제거 버튼
            IconButton(
              onPressed: widget.onRemove,
              icon: const Icon(Icons.remove_circle, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
