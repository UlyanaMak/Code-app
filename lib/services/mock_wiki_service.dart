import 'wiki_api_service.dart';
import '../models/lab.dart';
import '../models/lab_section.dart';

class MockWikiService implements WikiApiService {
  // Мок-данные те же, но без необходимости поддерживать search
  final List<Lab> _mockLabs = [
    Lab(
      labId: 1,
      slug: 'lr01-introduction-and-tooling',
      title: 'Лабораторная работа №1: Введение и инструментарий',
      tags: ['console', 'csharp', 'basics'],
      sectionsCount: 8,
      sections: [
        LabSection(
          id: 'цель-задания',
          title: 'Цель задания',
          kind: 'goal',
          order: 1,
          contentMd: '''
1. Познакомиться с платформой .NET и языком C#
2. Научиться создавать консольные приложения
3. Освоить базовый ввод/вывод данных
''',
          tags: ['console', 'csharp', 'теория'],
          assets: [],
        ),
        LabSection(
          id: 'теоретические-сведения',
          title: 'Теоретические сведения',
          kind: 'theory',
          order: 2,
          contentMd: '''
## Класс Console
- `Console.WriteLine()` - вывод строки
- `Console.ReadLine()` - чтение строки

```csharp
Console.WriteLine("Hello, World!");
string name = Console.ReadLine();
''',
tags: ['теория'],
assets: ['img-066.png'],
),
LabSection(
id: 'задание-1',
title: 'Задание №1',
kind: 'task',
order: 3,
contentMd: 'Создайте программу, которая выводит приветствие',
tags: ['задание'],
assets: [],
),
],
assets: [
Asset(
id: 'asset-001',
url: 'assets/lr01-introduction-and-tooling/assets/img-066.png',
type: 'image',
caption: 'Пример работы',
),
],
),
Lab(
labId: 2,
slug: 'lr02-conditionals-and-loops',
title: 'Лабораторная работа №2: Условные операторы и циклы',
tags: ['if', 'switch', 'for', 'while', 'csharp'],
sectionsCount: 10,
sections: [], // Без деталей для списка
assets: [],
),
Lab(
labId: 3,
slug: 'lr03-arrays-and-methods',
title: 'Лабораторная работа №3: Массивы и методы',
tags: ['array', 'method', 'function', 'csharp'],
sectionsCount: 9,
sections: [],
assets: [],
),
];

@override
Future<List<Lab>> getLabs() async {
await Future.delayed(const Duration(milliseconds: 800));
// Возвращаем только основную информацию, без sections
return _mockLabs.map((lab) => Lab(
labId: lab.labId,
slug: lab.slug,
title: lab.title,
tags: lab.tags,
sectionsCount: lab.sectionsCount,
)).toList();
}

@override
Future<Lab> getLabBySlug(String slug) async {
await Future.delayed(const Duration(milliseconds: 600));

final lab = _mockLabs.firstWhere(
(lab) => lab.slug == slug,
orElse: () => throw Exception('Лабораторная работа не найдена'),
);

return lab; // Возвращаем полные данные с sections
}

@override
String getAssetUrl(String assetPath) {
// Для моков возвращаем placeholder
return 'https://via.placeholder.com/800x400?text=Image+Placeholder';
}
}