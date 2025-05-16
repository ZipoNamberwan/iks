import 'package:iks/model/response/question_response.dart';

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
