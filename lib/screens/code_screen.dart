import 'package:course_project_code_app/screens/code_editor_screen.dart';
import 'package:flutter/material.dart';

class CodeScreen extends StatefulWidget {
  final String lessonTitle;
  final String lessonNumber;
  
  const CodeScreen({
    super.key, 
    required this.lessonTitle,
    required this.lessonNumber,
  });

  @override
  State<CodeScreen> createState() => _CodeStateScreen();
}

class _CodeStateScreen extends State<CodeScreen> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  
  // 2. ИНИЦИАЛИЗИРУЕМ
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
  }
  
  // 3. ОЧИЩАЕМ
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
        children: const [
          Center(child: Text('Задание')),  //!!!!!!!!!!!сделать вывод
          CodeEditorScreen(),
        ],
      ),


      

    );
  }
}