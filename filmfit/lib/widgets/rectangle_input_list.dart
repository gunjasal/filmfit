import 'package:flutter/material.dart';
import '../models/rectangle_input.dart';
import '../utils/color_palette.dart';
import '../widgets/rectangle_input_widget.dart';

class RectangleInputList extends StatefulWidget {
  final List<RectangleInput> rectangleInputs;
  final Function(List<RectangleInput>) onChanged;

  const RectangleInputList({
    Key? key,
    required this.rectangleInputs,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<RectangleInputList> createState() => _RectangleInputListState();
}

class _RectangleInputListState extends State<RectangleInputList> {
  void _addRectangleInput() {
    final newInput = RectangleInput(
      color: ColorPalette.getColor(widget.rectangleInputs.length),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    
    final updatedList = List<RectangleInput>.from(widget.rectangleInputs)
      ..add(newInput);
    
    widget.onChanged(updatedList);
  }

  void _removeRectangleInput(int index) {
    final updatedList = List<RectangleInput>.from(widget.rectangleInputs)
      ..removeAt(index);
    
    widget.onChanged(updatedList);
  }

  void _updateRectangleInput(int index, RectangleInput updatedInput) {
    final updatedList = List<RectangleInput>.from(widget.rectangleInputs);
    updatedList[index] = updatedInput;
    
    widget.onChanged(updatedList);
  }

  void _resetAll() {
    final newInput = RectangleInput(
      color: ColorPalette.getColor(0),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    
    widget.onChanged([newInput]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 버튼들
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _resetAll,
              child: const Text('모두 초기화'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addRectangleInput,
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // RectangleInput 리스트
        Expanded(
          child: ListView.builder(
            itemCount: widget.rectangleInputs.length,
            itemBuilder: (context, index) {
              return RectangleInputWidget(
                rectangleInput: widget.rectangleInputs[index],
                onRemove: widget.rectangleInputs.length > 1
                    ? () => _removeRectangleInput(index)
                    : () {}, // 마지막 하나는 제거 불가
                onChanged: (updatedInput) => _updateRectangleInput(index, updatedInput),
              );
            },
          ),
        ),
      ],
    );
  }
}
