import 'package:iks/model/survey/option.dart';
import 'package:iks/model/survey/question_type.dart';
import 'package:iks/model/survey/validation.dart';

class Question {
  final String id;
  final String text;
  final String? hint;
  final QuestionType type;
  final List<Option>? options;
  final List<ValidationRule>? validationRules;
  final bool allowMultiple; // For checkbox type
  final dynamic defaultValue;

  Question({
    required this.id,
    required this.text,
    this.hint,
    required this.type,
    this.options,
    this.validationRules,
    this.allowMultiple = false,
    this.defaultValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'hint': hint,
      'type': type.toString(),
      'options': options?.map((o) => o.toJson()).toList(),
      'validationRules': validationRules?.map((v) => v.toJson()).toList(),
      'allowMultiple': allowMultiple,
      'defaultValue': defaultValue,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      hint: json['hint'],
      type: QuestionType.values.firstWhere((e) => e.toString() == json['type'],
          orElse: () => QuestionType.text),
      options: json['options'] != null
          ? (json['options'] as List).map((o) => Option.fromJson(o)).toList()
          : null,
      validationRules: json['validationRules'] != null
          ? (json['validationRules'] as List)
              .map((v) => ValidationRule.fromJson(v))
              .toList()
          : null,
      allowMultiple: json['allowMultiple'] ?? false,
      defaultValue: json['defaultValue'],
    );
  }
}
