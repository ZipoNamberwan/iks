import 'dart:convert';
import 'package:iks/model/response/question_response.dart';
import 'package:iks/model/response/survey_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service for storing and retrieving survey responses locally.
/// In a real application, this would also sync with a remote database.
class SurveyStorageService {
  static const _keyPrefix = 'survey_response_';

  /// Save a section response to local storage
  Future<void> saveSectionResponse(
    String surveyId,
    Map<String, QuestionResponse> sectionResponses,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get the existing survey response if it exists
      final String? existingResponseJson =
          prefs.getString('$_keyPrefix$surveyId');
      Map<String, dynamic> surveyResponseMap = {};

      if (existingResponseJson != null) {
        surveyResponseMap = jsonDecode(existingResponseJson);

        // Update the question responses map
        final questionResponsesMap = Map<String, dynamic>.from(
            surveyResponseMap['questionResponses'] ?? {});

        for (final entry in sectionResponses.entries) {
          questionResponsesMap[entry.key] = entry.value.toJson();
        }

        surveyResponseMap['questionResponses'] = questionResponsesMap;
        surveyResponseMap['updatedAt'] = DateTime.now().toIso8601String();
      } else {
        // Create a new response
        final questionResponsesMap = {
          for (final entry in sectionResponses.entries)
            entry.key: entry.value.toJson(),
        };

        surveyResponseMap = {
          'surveyId': surveyId,
          'questionResponses': questionResponsesMap,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
      }

      // Save updated response
      await prefs.setString(
        '$_keyPrefix$surveyId',
        jsonEncode(surveyResponseMap),
      );
    } catch (e) {
      throw Exception('Failed to save section response: $e');
    }
  }

  /// Get a survey response from local storage
  Future<SurveyResponse?> getSurveyResponse(String surveyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? responseJson = prefs.getString('$_keyPrefix$surveyId');

      if (responseJson == null) {
        return null;
      }

      // TODO: Implement proper deserialization from JSON to SurveyResponse
      // This is a placeholder for now
      return null;
    } catch (e) {
      throw Exception('Failed to retrieve survey response: $e');
    }
  }

  /// Save the completed survey response
  Future<void> saveSurveyResponse(SurveyResponse surveyResponse) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update the timestamp
      surveyResponse.updatedAt = DateTime.now();

      // Save the survey response
      await prefs.setString(
        '$_keyPrefix${surveyResponse.surveyId}',
        jsonEncode(surveyResponse.toJson()),
      );
    } catch (e) {
      throw Exception('Failed to save survey response: $e');
    }
  }

  /// Clear all survey responses from local storage
  Future<void> clearAllResponses() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get all keys that start with our prefix
      final allKeys = prefs.getKeys();
      final surveyKeys = allKeys.where((key) => key.startsWith(_keyPrefix));

      // Remove all survey response keys
      for (final key in surveyKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      throw Exception('Failed to clear survey responses: $e');
    }
  }
}
