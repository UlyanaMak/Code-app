// lib/screens/labs_list_screen.dart

import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../models/lab.dart';
import 'code_screen.dart'; // ← сразу на CodeScreen

class LabsListScreen extends StatefulWidget {
  const LabsListScreen({super.key});

  @override
  State<LabsListScreen> createState() => _LabsListScreenState();
}

class _LabsListScreenState extends State<LabsListScreen> {
  final wikiService = ServiceLocator.wikiService;
  late Future<List<Lab>> _labsFuture;

  @override
  void initState() {
    super.initState();
    _labsFuture = wikiService.getLabs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лабораторные работы'),
        elevation: 2,
      ),
      body: FutureBuilder<List<Lab>>(
        future: _labsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final labs = snapshot.data ?? [];
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: labs.length,
            itemBuilder: (context, index) {
              final lab = labs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(lab.title),
                  subtitle: Text('Разделов: ${lab.sectionsCount}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    // Загружаем полные данные
                    final fullLab = await wikiService.getLabBySlug(lab.slug);
                    
                    // Переходим СРАЗУ на CodeScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CodeScreen(
                          lessonNumber: '${lab.labId}',
                          lessonTitle: lab.title,
                          fullLab: fullLab, // ← передаем все данные
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}