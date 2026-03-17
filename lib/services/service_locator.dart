
import 'wiki_api_service.dart';
import 'mock_wiki_service.dart';
// import 'real_wiki_service.dart'; // будет нужен, когда появится реальный API

class ServiceLocator {
  // текущий сервис
  static late WikiApiService wikiService;
  
  // метод инициализации
  static void init({bool useMock = true}) {
    if (useMock) {
      // пока мок-данные для разработки
      wikiService = MockWikiService();
    } else {
      // когда бэкенд будет готов, переключить сюда
      // wikiService = RealWikiService(baseUrl: 'https://api.example.com');
    }
  }
}