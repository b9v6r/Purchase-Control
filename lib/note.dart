class Note {
  String content;

  Note({
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      content: map['content'] ?? '',
    );
  }
}
