import 'package:course_project_code_app/screens/code_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/lab.dart';

class CodeScreen extends StatefulWidget {
  final String lessonTitle;
  final String lessonNumber;
  final Lab fullLab; //ТЗ работы
  
  const CodeScreen({
    super.key, 
    required this.lessonTitle,
    required this.lessonNumber,
    required this.fullLab,
  });

  @override
  State<CodeScreen> createState() => _CodeStateScreen();
}

class _CodeStateScreen extends State<CodeScreen> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  String get _taskText {
    final sections = widget.fullLab.sections ?? [];
    
    if (sections.isEmpty) {
      return 'Нет задания для этой лабораторной работы';
    }
    
    //поиск task
    final taskSection = sections.firstWhere(
      (section) => section.kind == 'task',
      orElse: () => throw Exception('No task'), // временное исключение
    );
    
    //поиск goal или theory
    final fallbackSection = sections.firstWhere(
      (section) => section.kind == 'goal' || section.kind == 'theory',
      orElse: () => throw Exception('No fallback'), // временное исключение
    );
    
    //получение текста
    try {
      return taskSection.contentMd;
    } catch (e) {
      try {
        return fallbackSection.contentMd;
      } catch (e) {
        return sections.first.contentMd;
      }
    }
  }
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120), //высота
        child: Container(

          decoration: BoxDecoration(
            color: Colors.white,
          ),

          child: SafeArea(
            child: Column(
              children: [
                // Верхняя строка с кнопкой назад и названием
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      //кнопка назад
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF334EAC)),
                        onPressed: () {
                          Navigator.pop(context); //возврат на предыдущий экран
                        },
                      ),
                      const SizedBox(width: 8),
                      
                      //название работы
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
                            Text(
                              widget.lessonTitle,
                              style: const TextStyle(
                                color: Color(0xFF334EAC),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                  labelStyle: TextStyle(fontSize: 18),
                  unselectedLabelColor: const Color(0xFF334EAC),
                  indicatorColor: const Color(0xFF6E97EC),
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: 'Задание'),
                    Tab(text: 'Код'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskTab(), //вывод текста задания
          const CodeEditorScreen(),
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
            //информация о лабораторной работе
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
            
            // Заголовок
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF6E97EC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF6E97EC).withOpacity(0.3),
                ),
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
            
            // Текст задания
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
}