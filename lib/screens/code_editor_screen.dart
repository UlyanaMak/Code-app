import 'package:flutter/material.dart';
// import 'package:flutter_highlighting/flutter_highlighting.dart';
// import 'package:flutter_highlighting/themes/github.dart';
import 'package:flutter_highlighting/themes/vs.dart';
import 'package:highlighting/languages/csharp.dart';
import 'package:highlighting/highlighting.dart';
import '../services/cloud_executor_service.dart';

class HighlightingCSharpController extends TextEditingController {
  final Map<String, TextStyle> theme;
  //late final highlight_lib.HighlightV2 _highlighter;
  String? _lastText;
  TextSpan? _lastResult;

  HighlightingCSharpController({
    this.theme = vsTheme,  //тема для поддержки подсветки
    String? text,
  }): super(text: text ?? '');

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
      final result = highlight.parse(
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
    required List<Node>? nodes,  //обязательно с highlight из пакета
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

  final CloudExecutorService _executor = CloudExecutorService();
  String _output = '';
  bool _isExecuting = false;

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

  Future<void> _executeCode() async {
    if (_isExecuting) return;
    
    setState(() {
      _isExecuting = true;
      _output = '⏳ Выполнение кода...';
    });

    try {
      final code = _codeController.text;
      
      // Здесь будет реальный вызов C# исполнителя
      final result = await _executor.executeCode(code);
      
      setState(() {
        _output = result;
        _isExecuting = false;
      });
    } catch (e) {
      setState(() {
        _output = '❌ Ошибка: $e';
        _isExecuting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Редактор кода C#',
          style: TextStyle(color: Color(0xFF334EAC)),
        ),
        actions: [
          // Кнопка запуска
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _isExecuting ? null : _executeCode,
              icon: _isExecuting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isExecuting ? 'Выполняется...' : 'Запустить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E97EC),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Редактор кода (занимает 2/3 экрана)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
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
          
          // Разделительная линия
          const Divider(height: 1, thickness: 1),
          
          // Область вывода результата (занимает 1/3 экрана)
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF1E1E1E), // Тёмный фон как в консоли
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок с иконкой
                  Row(
                    children: [
                      const Icon(
                        Icons.terminal,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Результат выполнения:',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Кнопка очистки
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                        onPressed: () {
                          setState(() {
                            _output = '';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Текст результата
                  Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _output.isEmpty 
                            ? '> Нажмите кнопку "Запустить" для выполнения кода' 
                            : _output,
                        style: const TextStyle(
                          fontFamily: 'Courier New',
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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