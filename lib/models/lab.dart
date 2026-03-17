//База знаний (Саша)
//Модель данных - лабораторная работа
import 'lab_section.dart';

class Lab {
  final int labId;
  final String slug;
  final String title;
  final List<String> tags;
  final int sectionsCount;
  List<LabSection>? sections; // будет заполняться при детальном запросе
  List<Asset>? assets;

  Lab({
    required this.labId,
    required this.slug,
    required this.title,
    required this.tags,
    required this.sectionsCount,
    this.sections,
    this.assets,
  });

  factory Lab.fromJson(Map<String, dynamic> json) {
    return Lab(
      labId: json['lab_id'],
      slug: json['slug'],
      title: json['title'],
      tags: List<String>.from(json['tags'] ?? []),
      sectionsCount: json['sections_count'] ?? 0,
      sections: json['sections'] != null
          ? List<LabSection>.from(
              json['sections'].map((s) => LabSection.fromJson(s)))
          : null,
      assets: json['assets'] != null
          ? List<Asset>.from(json['assets'].map((a) => Asset.fromJson(a)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'lab_id': labId,
        'slug': slug,
        'title': title,
        'tags': tags,
        'sections_count': sectionsCount,
        if (sections != null) 'sections': sections!.map((s) => s.toJson()).toList(),
        if (assets != null) 'assets': assets!.map((a) => a.toJson()).toList(),
      };
}