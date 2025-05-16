
class QuestionResponse {
  final String questionId;
  dynamic value;
  bool isValid;
  String? validationMessage;

  QuestionResponse({
    required this.questionId,
    this.value,
    this.isValid = true,
    this.validationMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'value': value,
      'isValid': isValid,
      'validationMessage': validationMessage,
    };
  }
}
