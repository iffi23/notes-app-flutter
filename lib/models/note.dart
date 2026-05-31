class Note {
  final int? id;
  final String title;
  final String content;
  final int colorValue; // Store ARGB color int value
  final String createdAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.colorValue,
    required this.createdAt,
  });

  // Convert a Note object into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'colorValue': colorValue,
      'createdAt': createdAt,
    };
  }

  // Extract a Note object from a Map.
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      colorValue: map['colorValue'] as int,
      createdAt: map['createdAt'] as String,
    );
  }

  // Helper method to copy a note with some new fields
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? colorValue,
    String? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
