import 'package:flutter/material.dart';

class CodeEditorScreen extends StatefulWidget {
  const CodeEditorScreen({super.key});

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  final TextEditingController _codeController = TextEditingController(
    text: '''using System;
class Program
{
  static void Main()
  {
    Console.WriteLine("Hello, World!");
  }
}''',
  );

  final double _fontSize = 14;
  final double _lineHeight = 24;
  final ScrollController _verticalScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: Scrollbar(
        controller: _verticalScrollController,
        child: SingleChildScrollView(
          controller: _verticalScrollController,
          scrollDirection: Axis.vertical,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNumbers(),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: 800,
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildCodeEditor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumbers() {
    final lines = _codeController.text.split('\n');
    
    return Container(
      width: 40,
      color: const Color(0xFFF0F0F0),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: List.generate(
          lines.length,
          (index) => Container(
            //высота по умолчанию
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Courier New',
                fontSize: _fontSize,
                height: _lineHeight / _fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeEditor() {
    return TextField(
      controller: _codeController,
      maxLines: null,
      style: TextStyle(
        fontFamily: 'Courier New',
        fontSize: _fontSize,
        height: _lineHeight / _fontSize,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8),
      ),
      onChanged: (text) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}