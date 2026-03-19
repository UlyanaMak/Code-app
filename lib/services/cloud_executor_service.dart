// lib/services/cloud_executor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudExecutorService {
  static final CloudExecutorService _instance = CloudExecutorService._internal();
  factory CloudExecutorService() => _instance;
  CloudExecutorService._internal();
  
  bool _isInitialized = false;
  
  // Ваши ключи JDoodle
  final String _clientId = 'd3d4b511c01c86d75895bbff8604bb22';
  final String _clientSecret = 'f6b64bf1a867fb61841cc6191935e753152c1cf1d66384c702ff18e44bb44ea5';
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final response = await http.post(
        Uri.parse('https://api.jdoodle.com/v1/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'script': 'Console.WriteLine("test");',
          'language': 'csharp',
          'versionIndex': '4',
          'clientId': _clientId,
          'clientSecret': _clientSecret
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print('✅ JDoodle API доступен');
        _isInitialized = true;
      } else {
        print('⚠️ JDoodle вернул ошибку ${response.statusCode}: ${response.body}');
        _isInitialized = true;
      }
    } catch (e) {
      print('⚠️ JDoodle недоступен, но пробуем выполнить код: $e');
      _isInitialized = true;
    }
  }
  
  /// Выполнение кода с поддержкой ввода
  /// [code] - код C# для выполнения
  /// [input] - строка ввода для Console.ReadLine() (опционально)
  Future<String> executeCode(String code, {String? input}) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Формируем тело запроса
      final Map<String, dynamic> requestBody = {
        'script': code,
        'language': 'csharp',
        'versionIndex': '4',
        'clientId': _clientId,
        'clientSecret': _clientSecret
      };
      
      // Добавляем stdin, если передан ввод
      if (input != null && input.isNotEmpty) {
        requestBody['stdin'] = input;  // Важно: именно 'stdin' для JDoodle!
      }
      
      final response = await http.post(
        Uri.parse('https://api.jdoodle.com/v1/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Проверяем наличие ошибки
        if (data['error'] != null && data['error'].isNotEmpty) {
          return 'Ошибка выполнения:\n${data['error']}';
        }
        
        // Возвращаем вывод программы
        if (data['output'] != null && data['output'].isNotEmpty) {
          return data['output'];
        }
        
        return 'Код выполнен успешно (нет вывода)';
      } else {
        return 'Ошибка сервера (${response.statusCode}):\n${response.body}';
      }
    } catch (e) {
      return 'Ошибка соединения: $e.\nПроверьте интернет и правильность API ключей.';
    }
  }
  
  void dispose() {
    // Ничего не нужно
  }
}