import 'package:uuid/uuid.dart';

class SymptomModel {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isHindi;

  SymptomModel({
    String? id,
    required this.text,
    DateTime? timestamp,
    this.isHindi = true,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  SymptomModel copyWith({
    String? text,
    bool? isHindi,
  }) {
    return SymptomModel(
      id: id,
      text: text ?? this.text,
      timestamp: timestamp,
      isHindi: isHindi ?? this.isHindi,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'isHindi': isHindi,
      };

  factory SymptomModel.fromMap(Map<String, dynamic> map) => SymptomModel(
        id: map['id'],
        text: map['text'],
        timestamp: DateTime.parse(map['timestamp']),
        isHindi: map['isHindi'] ?? true,
      );

  @override
  String toString() => 'SymptomModel(id: $id, text: $text)';
}
