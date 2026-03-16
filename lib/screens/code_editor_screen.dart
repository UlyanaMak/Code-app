import 'package:flutter/material.dart';
import 'package:flutter_highlighting/flutter_highlighting.dart';
import 'package:flutter_highlighting/themes/github.dart';
import 'package:flutter_highlighting/themes/vs.dart';
import 'package:highlighting/languages/csharp.dart';
import 'package:highlighting/highlighting.dart' as highlight_lib;

class HighlightingCSharpController extends TextEditingController {
  final Map<String, TextStyle> theme;
  late final highlight_lib.HighlightV2 _highlighter;
  String? _lastText;
  TextSpan? _lastResult;

  HighlightingCSharpController({
    this.theme = vsTheme,  //тема для поддержки подсветки
    String? text,
  }): super(text: text ?? '') {
    _highlighter = highlight_lib.HighlightV2();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final currentText = text;
    
    // Если текст не изменился, возвращаем кэшированный результат
    if (_lastText == currentText && _lastResult != null) {
      return _lastResult!;
    }
    
    if (currentText.isEmpty) {
      return TextSpan(style: style, text: '');
    }

    try {
      // Парсим код с подсветкой синтаксиса C#
      final result = _highlighter.parse(
        currentText,
        languageId: csharp.id, // Используем идентификатор C# из библиотеки
      );

      // Строим дерево TextSpan
      final spans = _buildSpans(
        nodes: result.nodes,
        theme: theme,
        defaultStyle: style,
      );

      final textSpan = TextSpan(children: spans, style: style);
      
      // Кэшируем результат
      _lastText = currentText;
      _lastResult = textSpan;
      
      return textSpan;
    } catch (e) {
      // В случае ошибки показываем обычный текст
      return TextSpan(style: style, text: currentText);
    }
  }

  List<TextSpan> _buildSpans({
    required List<highlight_lib.Node>? nodes,  //обязательно с highlight из пакета
    required Map<String, TextStyle> theme,
    required TextStyle? defaultStyle,
  }) {
    if (nodes == null) return [];
    
    return nodes.map((node) {
      // Получаем стиль для текущего класса узла
      final nodeStyle = node.className != null && theme.containsKey(node.className)
          ? theme[node.className]
          : defaultStyle;
      
      // Рекурсивно обрабатываем дочерние узлы
      final children = node.children != null && node.children!.isNotEmpty
          ? _buildSpans(nodes: node.children, theme: theme, defaultStyle: nodeStyle)
          : null;
      
      return TextSpan(
        text: node.value,
        style: nodeStyle,
        children: children,
      );
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CodeEditorScreen extends StatefulWidget {
  const CodeEditorScreen({super.key});

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  
  
  //подсветка текста
  late final HighlightingCSharpController _codeController;

  

  final double _fontSize = 14;
  final double _lineHeight = 24;
  final ScrollController _verticalScrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _codeController = HighlightingCSharpController(
    text: '''using System;
class Program
{
  static void Main()
  {
    Console.WriteLine("Hello, World!");
  }
}''',
  );

  _codeController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {}); // Обновляем UI при изменении текста
  }

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
      //onChange убрано
    );
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _codeController.dispose();
    _codeController.removeListener(_onTextChanged);
    super.dispose();
  }
}