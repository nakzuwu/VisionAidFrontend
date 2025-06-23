class Note {
  final String id;
  final String title;
  final String content;
  final String folder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;
  final bool isSynced;
  final DateTime? lastOpened;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.folder,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
    this.isSynced = false,
    this.lastOpened,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? folder,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? images,
    bool? isSynced,
    DateTime? lastOpened,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      folder: folder ?? this.folder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      isSynced: isSynced ?? this.isSynced,
      lastOpened: lastOpened ?? this.lastOpened,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      folder: json['folder'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      images: List<String>.from(json['images'] ?? []),
      isSynced: true,
    );
  }
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      folder: map['folder'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      images: List<String>.from(map['images'] ?? []),
      isSynced: map['isSynced'] ?? false,
      lastOpened: map['lastOpened'] != null
          ? DateTime.tryParse(map['lastOpened']) ?? DateTime.now()
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'folder': folder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'images': images,
      'isSynced': isSynced,
      'lastOpened': lastOpened?.toIso8601String(),
    };
  }
}
