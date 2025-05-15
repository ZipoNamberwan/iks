class SurveyResponse {
  final String surveyId;
  final Map<String, SectionResponse> sectionResponses;
  DateTime createdAt;
  DateTime? updatedAt;

  SurveyResponse({
    required this.surveyId,
    required this.sectionResponses,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> sectionResponsesJson = {};
    sectionResponses.forEach((key, value) {
      sectionResponsesJson[key] = value.toJson();
    });

    return {
      'surveyId': surveyId,
      'sectionResponses': sectionResponsesJson,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class SectionResponse {
  final String sectionId;
  final Map<String, QuestionResponse> responses;
  bool isComplete;

  SectionResponse({
    required this.sectionId,
    required this.responses,
    this.isComplete = false,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> responsesJson = {};
    responses.forEach((key, value) {
      responsesJson[key] = value.toJson();
    });

    return {
      'sectionId': sectionId,
      'responses': responsesJson,
      'isComplete': isComplete,
    };
  }
}

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
