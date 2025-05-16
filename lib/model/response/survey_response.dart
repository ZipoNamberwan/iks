import 'package:iks/model/response/section_response.dart';

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