import 'dart:convert';
import 'package:iks/model/response/survey_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service for storing and retrieving survey responses locally.
/// In a real application, this would also sync with a remote database.
class SurveyStorageService {
  static const _keyPrefix = 'survey_response_';

  /// Save a section response to local storage
  Future<void> saveSectionResponse(
    String surveyId,
    String sectionId,
    SectionResponse sectionResponse,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get the existing survey response if it exists
      final String? existingResponseJson =
          prefs.getString('$_keyPrefix$surveyId');
      Map<String, dynamic> surveyResponseMap = {};

      if (existingResponseJson != null) {
        surveyResponseMap = jsonDecode(existingResponseJson);

        // Update the section responses with the new section response
        final sectionResponsesMap =
            surveyResponseMap['sectionResponses'] as Map<String, dynamic>;
        sectionResponsesMap[sectionId] = sectionResponse.toJson();

        // Update the timestamp
        surveyResponseMap['updatedAt'] = DateTime.now().toIso8601String();
      } else {
        // Create a new survey response
        final Map<String, dynamic> sectionResponsesMap = {
          sectionId: sectionResponse.toJson(),
        };

        surveyResponseMap = {
          'surveyId': surveyId,
          'sectionResponses': sectionResponsesMap,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
      }

      // Save the updated survey response
      await prefs.setString(
        '$_keyPrefix$surveyId',
        jsonEncode(surveyResponseMap),
      );

      print('Saved section response to local storage: $sectionId');
    } catch (e) {
      print('Error saving section response: $e');
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
      print('Retrieved survey response from local storage: $surveyId');
      return null;
    } catch (e) {
      print('Error retrieving survey response: $e');
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

      print(
          'Saved complete survey response to local storage: ${surveyResponse.surveyId}');
    } catch (e) {
      print('Error saving survey response: $e');
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

      print('Cleared all survey responses from local storage');
    } catch (e) {
      print('Error clearing survey responses: $e');
      throw Exception('Failed to clear survey responses: $e');
    }
  }
}
