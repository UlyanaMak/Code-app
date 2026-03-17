class LabSection {
  final String id;
  final String title;
  final String kind;
  final int order;
  final String contentMd;
  final List<String> tags;
  final List<String> assets;

  LabSection({
    required this.id,
    required this.title,
    required this.kind,
    required this.order,
    required this.contentMd,
    required this.tags,
    required this.assets,
  });

  factory LabSection.fromJson(Map<String, dynamic> json) {
    return LabSection(
      id: json['id'],
      title: json['title'],
      kind: json['kind'],
      order: json['order'],
      contentMd: json['content_md'],
      tags: List<String>.from(json['tags'] ?? []),
      assets: List<String>.from(json['assets'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'kind': kind,
        'order': order,
        'content_md': contentMd,
        'tags': tags,
        'assets': assets,
      };
}

class Asset {
  final String id;
  final String url;
  final String type;
  final String caption;

  Asset({
    required this.id,
    required this.url,
    required this.type,
    required this.caption,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      url: json['url'],
      type: json['type'],
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'type': type,
        'caption': caption,
      };
}