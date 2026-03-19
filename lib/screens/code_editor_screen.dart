import 'package:flutter/material.dart';
import 'package:flutter_highlighting/themes/vs.dart';
import 'package:highlighting/languages/csharp.dart';
import 'package:highlighting/highlighting.dart';

class HighlightingCSharpController extends TextEditingController {
  final Map<String, TextStyle> theme;
  String? _lastText;
  TextSpan? _lastResult;

  HighlightingCSharpController({
    this.theme = vsTheme,
    String? text,
  }): super(text: text ?? '');

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final currentText = text;
    
    if (_lastText == currentText && _lastResult != null) {
      return _lastResult!;
    }
    
    if (currentText.isEmpty) {
      return TextSpan(style: style, text: '');
    }

    try {
      final result = highlight.parse(
        currentText,
        languageId: csharp.id,
      );

      final spans = _buildSpans(
        nodes: result.nodes,
        theme: theme,
        defaultStyle: style,
      );

      final textSpan = TextSpan(children: spans, style: style);
      
      _lastText = currentText;
      _lastResult = textSpan;
      
      return textSpan;
    } catch (e) {
      return TextSpan(style: style, text: currentText);
    }
  }

  List<TextSpan> _buildSpans({
    required List<Node>? nodes,
    required Map<String, TextStyle> theme,
    required TextStyle? defaultStyle,
  }) {
    if (nodes == null) return [];
    
    return nodes.map((node) {
      final nodeStyle = node.className != null && theme.containsKey(node.className)
          ? theme[node.className]
          : defaultStyle;
      
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
}

class CodeEditorScreen extends StatefulWidget {
  final Function(String) onExecute;
  final bool isExecuting;
  final String initialCode;
  
  const CodeEditorScreen({
    super.key,
    required this.onExecute,
    required this.isExecuting,
    this.initialCode = '',
  });

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  late final HighlightingCSharpController _codeController;
  
  final double _fontSize = 14;
  final double _lineHeight = 24;
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _codeController = HighlightingCSharpController(
      text: widget.initialCode.isNotEmpty 
          ? widget.initialCode
          : '''using System;
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false, 
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: widget.isExecuting ? null : () => widget.onExecute(_codeController.text),
              icon: widget.isExecuting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(widget.isExecuting ? 'Выполняется...' : 'Запустить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E97EC),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(  // ← ДОБАВЛЯЕМ ВЕРТИКАЛЬНЫЙ СКРОЛЛ
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
                    child: TextField(
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
                    ),
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
            height: _fontSize * (_lineHeight / _fontSize),
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

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _codeController.removeListener(_onTextChanged);
    _codeController.dispose();
    super.dispose();
  }
}