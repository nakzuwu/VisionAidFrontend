class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? lastOpened;
  
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.lastOpened,
  });
  
  // Add copyWith method
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? lastOpened,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      lastOpened: lastOpened ?? this.lastOpened,
    );
  }
}