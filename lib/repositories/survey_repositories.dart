import 'dart:async';

import 'package:iks/model/response/survey_response.dart';
import 'package:iks/model/survey/question_type.dart';
import 'package:iks/model/survey/survey.dart';
import 'package:iks/model/survey/validation.dart';

class SurveyRepository {
  // In a real app, this would connect to a database or API
  // For demonstration purposes, we're using in-memory storage
  final Map<String, Survey> _surveys = {};
  final Map<String, SurveyResponse> _responses = {};

  // Load a survey by ID
  Future<Survey> getSurvey(String surveyId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (_surveys.containsKey(surveyId)) {
      return _surveys[surveyId]!;
    }

    // For demo purposes, create a sample survey if not found
    final survey = _createSampleSurvey(surveyId);
    _surveys[surveyId] = survey;
    return survey;
  }

  // Save a section response
  Future<void> saveSectionResponse(
    String surveyId,
    String sectionId,
    SectionResponse sectionResponse,
  ) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 200));

    // Check if we already have a response for this survey
    if (!_responses.containsKey(surveyId)) {
      _responses[surveyId] = SurveyResponse(
        surveyId: surveyId,
        sectionResponses: {},
      );
    }

    // Update the section response
    _responses[surveyId]!.sectionResponses[sectionId] = sectionResponse;
    _responses[surveyId]!.updatedAt = DateTime.now();

  }

  // Submit the entire survey
  Future<SurveyResponse> submitSurvey(SurveyResponse surveyResponse) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Store the response
    _responses[surveyResponse.surveyId] = surveyResponse;
    surveyResponse.updatedAt = DateTime.now();

    return surveyResponse;
  }

  // Helper method to create a sample survey for demo purposes
  Survey _createSampleSurvey(String surveyId) {
    return Survey(
      id: surveyId,
      title: 'Sample Survey',
      description:
          'This is a demonstration survey with multiple sections and question types',
      sections: [
        Section(
          id: 'section_identification',
          title: 'Identification',
          description: 'Basic personal information',
          questions: [
            Question(
              id: 'name',
              text: 'What is your full name?',
              hint: 'Enter your full name as it appears on official documents',
              type: QuestionType.text,
              validationRules: [
                ValidationRule(
                  id: 'name_required',
                  type: 'required',
                  message: 'Please enter your name',
                ),
              ],
            ),
            Question(
              id: 'email',
              text: 'What is your email address?',
              hint: 'e.g. name@example.com',
              type: QuestionType.text,
              validationRules: [
                ValidationRule(
                  id: 'email_required',
                  type: 'required',
                  message: 'Please enter your email address',
                ),
              ],
            ),
            Question(
              id: 'phone',
              text: 'What is your phone number?',
              hint: 'e.g. +1 (123) 456-7890',
              type: QuestionType.text,
            ),
            Question(
              id: 'age',
              text: 'What is your age?',
              hint: 'Enter your age in years',
              type: QuestionType.number,
              validationRules: [
                ValidationRule(
                  id: 'age_required',
                  type: 'required',
                  message: 'Please enter your age',
                ),
              ],
            ),
          ],
        ),
        Section(
          id: 'section_demographics',
          title: 'Demographics',
          description: 'Information about yourself',
          questions: [
            Question(
              id: 'gender',
              text: 'What is your gender?',
              type: QuestionType.radio,
              options: [
                Option(id: 'gender_male', label: 'Male', value: 'male'),
                Option(id: 'gender_female', label: 'Female', value: 'female'),
                Option(id: 'gender_other', label: 'Other', value: 'other'),
                Option(
                    id: 'gender_prefer_not',
                    label: 'Prefer not to say',
                    value: 'prefer_not_to_say'),
              ],
            ),
            Question(
              id: 'marital_status',
              text: 'What is your marital status?',
              type: QuestionType.radio,
              options: [
                Option(id: 'status_single', label: 'Single', value: 'single'),
                Option(
                    id: 'status_married', label: 'Married', value: 'married'),
                Option(
                    id: 'status_divorced',
                    label: 'Divorced',
                    value: 'divorced'),
                Option(
                    id: 'status_widowed', label: 'Widowed', value: 'widowed'),
              ],
              validationRules: [
                ValidationRule(
                  id: 'marital_age_validation',
                  type: 'dependency',
                  message: 'You must be at least 18 years old to be married',
                  dependsOnQuestionId: 'age',
                  dependsOnValue: 'married',
                  condition: {'min': 18},
                ),
              ],
            ),
          ],
        ),
        Section(
          id: 'section_education',
          title: 'Education',
          description: 'Information about your educational background',
          questions: [
            Question(
              id: 'education_level',
              text: 'What is your highest level of education?',
              type: QuestionType.dropdown,
              options: [
                Option(
                    id: 'edu_high_school',
                    label: 'High School',
                    value: 'high_school'),
                Option(
                    id: 'edu_associates',
                    label: 'Associate\'s Degree',
                    value: 'associates'),
                Option(
                    id: 'edu_bachelors',
                    label: 'Bachelor\'s Degree',
                    value: 'bachelors'),
                Option(
                    id: 'edu_masters',
                    label: 'Master\'s Degree',
                    value: 'masters'),
                Option(
                    id: 'edu_doctorate',
                    label: 'Doctorate',
                    value: 'doctorate'),
              ],
            ),
            Question(
              id: 'fields_of_interest',
              text: 'What fields are you interested in?',
              hint: 'Select all that apply',
              type: QuestionType.checkbox,
              allowMultiple: true,
              options: [
                Option(
                    id: 'field_tech', label: 'Technology', value: 'technology'),
                Option(
                    id: 'field_health',
                    label: 'Healthcare',
                    value: 'healthcare'),
                Option(id: 'field_edu', label: 'Education', value: 'education'),
                Option(
                    id: 'field_business', label: 'Business', value: 'business'),
                Option(id: 'field_arts', label: 'Arts', value: 'arts'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
