class Memo {
  final String id;
  final String text;
  final String date;
  Memo({required this.id, required this.text, required this.date});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'text': text,
      'date': date
    };
  }
}