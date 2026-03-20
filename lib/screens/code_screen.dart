import 'package:course_project_code_app/screens/code_editor_screen.dart';
import 'package:course_project_code_app/screens/code_console_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/lab.dart';
import '../services/cloud_executor_service.dart';

class CodeScreen extends StatefulWidget {
  final String lessonTitle;
  final String lessonNumber;
  final Lab fullLab;
  
  const CodeScreen({
    super.key, 
    required this.lessonTitle,
    required this.lessonNumber,
    required this.fullLab,
  });

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> with TickerProviderStateMixin {
  // Сервис для выполнения кода
  final CloudExecutorService _executor = CloudExecutorService();
  //final InteractiveExecutorService _executor = InteractiveExecutorService();


  int _countReadLines(String code) {
    return RegExp(r'ReadLine\s*\(').allMatches(code).length;
  
  }
  // Данные для вкладок
  String _code = '';              // Код из редактора
  String _consoleOutput = '';     // Вывод консоли
  String _currentInput = '';      // Текущий ввод (для отправки)
  bool _isAwaitingInput = false;  // Флаг ожидания ввода
  bool _isExecuting = false;      // Флаг выполнения
  
  // Всегда существующие вкладки (теперь 3 фиксированные)
  final List<TabType> _fixedTabs = const [
    TabType.task, 
    TabType.code, 
    TabType.console
  ];
  
  // TabController - теперь с фиксированным количеством вкладок
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _fixedTabs.length,
      vsync: this,
      initialIndex: 0, //начинать с вкладки задания
    );
  }

  String get _taskText {
    final sections = widget.fullLab.sections ?? [];
    if (sections.isEmpty) return 'Нет задания для этой лабораторной работы';
    
    try {
      final taskSection = sections.firstWhere((s) => s.kind == 'task');
      return taskSection.contentMd;
    } catch (e) {
      try {
        final fallback = sections.firstWhere((s) => s.kind == 'goal' || s.kind == 'theory');
        return fallback.contentMd;
      } catch (e) {
        return sections.first.contentMd;
      }
    }
  }

  /// Получить заголовок вкладки по типу
  String _getTabTitle(TabType type) {
    switch (type) {
      case TabType.task:
        return 'Задание';
      case TabType.code:
        return 'Код';
      case TabType.console:
        return 'Консоль';
    }
  }

  /// Выполнение кода
  Future<void> _executeCode(String code, {bool isRetry = false}) async {
  if (_isExecuting) return;

  // Очищаем только при первом запуске
  if (!isRetry) {
    setState(() {
      _code = code;
      _isExecuting = true;
      _consoleOutput = '';
      _currentInput = '';
      _isAwaitingInput = false;
    });
  } else {
    setState(() {
      _isExecuting = true;
    });
  }

  if (!isRetry) {
    setState(() {
      _consoleOutput += '> Выполнение кода...\n';
    });
  }

  // Переключаемся на консоль
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _tabController.animateTo(2);
  });

  final readLineCount = _countReadLines(code);

  // Если есть ReadLine и нет ввода — запрашиваем
  if (readLineCount > 0 && _currentInput.isEmpty && !isRetry) {
    setState(() {
      _isAwaitingInput = true;
      _consoleOutput += '⏳ Программа требует следующее количество вводов: $readLineCount\n';
      _consoleOutput += '📝 Введите данные (каждое значение с новой строки):\n';
      _isExecuting = false;
    });
    return;
  }

  // Выполняем код с вводом
  final result = await _executor.executeCode(code, input: _currentInput);
  
  if (mounted) {
    setState(() {
      _consoleOutput += result;
      _isExecuting = false;
      _currentInput = '';
    });
  }
}


  /// Обработка ввода из консоли
  // Обновите _onInputSubmitted
  void _onInputSubmitted(String input) {
  if (!_isAwaitingInput) return;
  
  setState(() {
    // Добавляем ввод к накопленным данным
    _currentInput = (_currentInput + '\n' + input).trim();
    _consoleOutput += '> $input\n';
    
    final readLineCount = _countReadLines(_code);
    final inputCount = _currentInput.split('\n').where((s) => s.isNotEmpty).length;
    
    if (inputCount >= readLineCount) {
      // Ввода достаточно — выполняем код (НЕ ОЧИЩАЯ консоль)
      _isAwaitingInput = false;
      _consoleOutput += '▶️ Выполнение...\n';
      _executeCode(_code, isRetry: true);  // ← isRetry: true
    } else {
      // Ждём следующий ввод
      _consoleOutput += '⏳ Осталось ввести ${readLineCount - inputCount} значение(ий)\n';
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF334EAC)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Лабораторная работа №${widget.lessonNumber}',
                              style: const TextStyle(
                                color: Color(0xFF6E97EC),
                                fontSize: 14,
                              ),
                            ),
                            Tooltip(
                              message: _cleanLessonTitle,  // полный текст
                              child: Text(
                                _cleanLessonTitle,
                                style: const TextStyle(
                                  color: Color(0xFF334EAC),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF6E97EC),
                  labelStyle: const TextStyle(fontSize: 18),
                  unselectedLabelColor: const Color(0xFF334EAC),
                  indicatorColor: const Color(0xFF6E97EC),
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: _fixedTabs.map((type) => Tab(text: _getTabTitle(type))).toList(),
                ),
              ],
            ),
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // Вкладка Задание
          _buildTaskTab(),
          
          // Вкладка Код
          CodeEditorScreen(
            onExecute: _executeCode,
            isExecuting: _isExecuting,
            initialCode: _code,
          ),
          
          // Вкладка Консоль (единая)
          CodeConsoleScreen(
            output: _consoleOutput,
            onInputSubmitted: _onInputSubmitted,
            isAwaitingInput: _isAwaitingInput,
            onClear: _clearConsole,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTab() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF6E97EC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF334EAC)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: widget.fullLab.tags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          backgroundColor: Colors.white,
                          labelStyle: const TextStyle(fontSize: 12),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF6E97EC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF6E97EC).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment, color: const Color(0xFF334EAC)),
                  const SizedBox(width: 8),
                  const Text(
                    'Задание',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334EAC),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            MarkdownBody(
              data: _taskText,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                p: const TextStyle(fontSize: 16, height: 1.5),
                code: const TextStyle(
                  fontFamily: 'monospace',
                  backgroundColor: Color(0xFFF5F5F5),
                ),
                codeblockPadding: const EdgeInsets.all(12),
                listIndent: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    //_executor.disconnect();
    _tabController.dispose();
    _executor.dispose();
    super.dispose();
  }

  void _clearConsole() {
    setState(() {
      _consoleOutput = '';
      _currentInput = '';
      _isAwaitingInput = false;
    });
  } 

  String get _cleanLessonTitle {
    final title = widget.lessonTitle;
  
    // Если есть двоеточие, берём всё что после него
    if (title.contains(':')) {
      return title.substring(title.indexOf(':') + 1).trim();
    }
  
    // Если двоеточия нет (на всякий случай)
    return title;
  }
}



/// Типы вкладок
enum TabType { task, code, console }