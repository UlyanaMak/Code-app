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

  @override
  Widget build(BuildContext context) {
    final lines = _codeController.text.split('\n');
    
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        //вертикальный скроллинг для нумерации строк и кода
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //нумерация строк
            Container(
              width: 40,
              color: Color(0xFFF9F9F9),
              child: Column(
                children: List.generate(
                  lines.length,
                  (index) => Container(
                    height: 24,
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: const Color(0xFF000000),
                        fontFamily: 'Courier New',
                        fontSize: _fontSize, // размер шрифта
                        height: _lineHeight/_fontSize, // высота строки
                      ),
                    ),
                  ),
                ),
              ),
            ),

            //область кода с горизонтальным скроллом
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: 800, // фиксированная ширина для скролла
                  color: Color(0xFFF9F9F9),
                  padding: const EdgeInsets.only(left: 8),
                  child: TextField(
                    controller: _codeController,
                    maxLines: null,
                    style: TextStyle(
                      fontFamily: 'Courier New',
                      fontSize: _fontSize, // размер шрифта
                      height: _lineHeight/_fontSize, // высота строки
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,  //это убрало ненужные отступы у строк кода и они соответствуют нумерации
                    ),
                    onChanged: (text) => setState(() {}),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}