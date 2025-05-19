import 'package:iks/model/response/question_response.dart';

class SurveyResponse {
  final String surveyId;
  final Map<String, QuestionResponse> questionResponses;
  DateTime createdAt;
  DateTime? updatedAt;

  SurveyResponse({
    required this.surveyId,
    required this.questionResponses,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> questionResponsesJson = {};
    questionResponses.forEach((key, value) {
      questionResponsesJson[key] = value.toJson();
    });

    return {
      'surveyId': surveyId,
      'questionResponses': questionResponsesJson,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}