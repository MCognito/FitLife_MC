class LibraryItem {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;

  LibraryItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
  });

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB ObjectId format
    String extractId(dynamic idField) {
      if (idField is String) return idField;
      if (idField is Map && idField.containsKey('\$oid')) {
        return idField['\$oid'];
      }
      return '';
    }

    // Handle MongoDB Date format
    DateTime extractDate(dynamic dateField) {
      if (dateField is String) {
        return DateTime.tryParse(dateField) ?? DateTime.now();
      }
      if (dateField is Map && dateField.containsKey('\$date')) {
        if (dateField['\$date'] is String) {
          return DateTime.tryParse(dateField['\$date']) ?? DateTime.now();
        } else if (dateField['\$date'] is Map &&
            dateField['\$date'].containsKey('\$numberLong')) {
          return DateTime.fromMillisecondsSinceEpoch(
              int.parse(dateField['\$date']['\$numberLong']));
        }
      }
      return DateTime.now();
    }

    return LibraryItem(
      id: extractId(json['_id']),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      createdAt: json.containsKey('created_at')
          ? extractDate(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
