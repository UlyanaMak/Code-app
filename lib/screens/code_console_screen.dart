import 'package:flutter/material.dart';

class CodeConsoleScreen extends StatefulWidget {
  final String output;
  final Function(String) onInputSubmitted;
  final bool isAwaitingInput;
  final VoidCallback onClear;  // Добавлен параметр onClear
  
  const CodeConsoleScreen({
    super.key,
    required this.output,
    required this.onInputSubmitted,
    required this.isAwaitingInput,
    required this.onClear,  // Обязательный параметр
  });

  @override
  State<CodeConsoleScreen> createState() => _CodeConsoleScreenState();
}

class _CodeConsoleScreenState extends State<CodeConsoleScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(CodeConsoleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Если появился запрос ввода - фокусируем поле и скроллим вниз
    if (widget.isAwaitingInput && !oldWidget.isAwaitingInput) {
      _focusNode.requestFocus();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitInput() {
    if (_inputController.text.isNotEmpty) {
      widget.onInputSubmitted(_inputController.text);
      _inputController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          // Заголовок с кнопкой очистки
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              border: Border(
                bottom: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Консоль',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: widget.onClear,  // Используем переданную функцию
                ),
              ],
            ),
          ),
          
          // Область вывода
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: SelectableText(
                  widget.output.isEmpty 
                      ? '> Выполните код для начала работы' 
                      : widget.output,
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          
          // Строка ввода (появляется только когда нужна)
          if (widget.isAwaitingInput)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                border: Border(
                  top: BorderSide(color: Colors.grey[800]!),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '> ',
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'Courier New',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Courier New',
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _submitInput(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: _submitInput,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}