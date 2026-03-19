// lib/services/cloud_executor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudExecutorService {
  static final CloudExecutorService _instance = CloudExecutorService._internal();
  factory CloudExecutorService() => _instance;
  CloudExecutorService._internal();
  
  bool _isInitialized = false;
  
  // ⚠️ ВАЖНО: Замените эти значения на свои после регистрации на jdoodle.com
  final String _clientId = 'd3d4b511c01c86d75895bbff8604bb22';      // Вставьте ваш Client ID
  final String _clientSecret = 'f6b64bf1a867fb61841cc6191935e753152c1cf1d66384c702ff18e44bb44ea5'; // Вставьте ваш Secret Key
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Проверяем доступность API простым тестовым запросом
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
        _isInitialized = true; // Всё равно пробуем выполнить код
      }
    } catch (e) {
      print('⚠️ JDoodle недоступен, но пробуем выполнить код: $e');
      _isInitialized = true;
    }
  }
  
  Future<String> executeCode(String code) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Формируем запрос к JDoodle API
      final response = await http.post(
        Uri.parse('https://api.jdoodle.com/v1/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'script': code,
          'language': 'csharp',
          'versionIndex': '4',      // .NET 6.0 (рекомендуемая версия)
          'clientId': _clientId,
          'clientSecret': _clientSecret
        }),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // JDoodle возвращает результат в поле 'output'
        // Если есть ошибка, она будет в поле 'error'
        if (data['error'] != null && data['error'].isNotEmpty) {
          return 'Ошибка выполнения:\n${data['error']}';
        }
        
        if (data['output'] != null && data['output'].isNotEmpty) {
          return data['output'];
        }
        
        return 'Код выполнен успешно (нет вывода)';
      } else {
        // Если сервер вернул ошибку, выводим её
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