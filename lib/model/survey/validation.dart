class ValidationRule {
  final String id;
  final String type; // 'required', 'custom', 'dependency'
  final String? message;
  final dynamic condition; // Function or value to evaluate
  final String? dependsOnQuestionId; // For dependency validations
  final dynamic dependsOnValue; // Expected value(s) of the dependency

  ValidationRule({
    required this.id,
    required this.type,
    this.message,
    this.condition,
    this.dependsOnQuestionId,
    this.dependsOnValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'dependsOnQuestionId': dependsOnQuestionId,
      'dependsOnValue': dependsOnValue,
    };
  }

  factory ValidationRule.fromJson(Map<String, dynamic> json) {
    return ValidationRule(
      id: json['id'],
      type: json['type'],
      message: json['message'],
      dependsOnQuestionId: json['dependsOnQuestionId'],
      dependsOnValue: json['dependsOnValue'],
    );
  }
}

class ValidationResult {
  final bool isValid;
  final String? message;

  ValidationResult({
    required this.isValid,
    this.message,
  });
}
