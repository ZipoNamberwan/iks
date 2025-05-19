import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iks/model/response/question_response.dart';
import 'package:iks/model/response/survey_response.dart';
import 'package:iks/model/survey/question.dart';
import 'package:iks/model/survey/validation.dart';
import 'package:iks/repositories/survey_repositories.dart';
import 'survey_event.dart';
import 'survey_state.dart';

class SurveyBloc extends Bloc<SurveyEvent, SurveyState> {
  final SurveyRepository _surveyRepository;

  SurveyBloc(this._surveyRepository) : super(const SurveyInitial()) {
    on<LoadSurvey>(_onLoadSurvey);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<NavigateToNextQuestion>(_onNavigateToNextQuestion);
    on<NavigateToPreviousQuestion>(_onNavigateToPreviousQuestion);
    on<NavigateToQuestion>(_onNavigateToQuestion);
    on<NavigateToSection>(_onNavigateToSection);
    on<SaveSectionData>(_onSaveSectionData);
    on<ValidateSurvey>(_onValidateSurvey);
    on<SubmitSurvey>(_onSubmitSurvey);
  }

  Future<void> _onLoadSurvey(
    LoadSurvey event,
    Emitter<SurveyState> emit,
  ) async {
    emit(const SurveyLoading());

    try {
      final survey = await _surveyRepository.getSurvey(event.surveyId);

      // Flatten all question responses
      final Map<String, QuestionResponse> questionResponses = {};

      for (final section in survey.sections) {
        for (final question in section.questions) {
          questionResponses[question.id] = QuestionResponse(
            questionId: question.id,
            value: question.defaultValue,
          );
        }
      }

      final surveyResponse = SurveyResponse(
        surveyId: survey.id,
        questionResponses: questionResponses,
      );

      emit(SurveyLoaded(
        data: SurveyStateData(
          survey: survey,
          surveyResponse: surveyResponse,
          currentSectionIndex: 0,
          currentQuestionIndex: survey.sections.isNotEmpty &&
                  survey.sections[0].questions.isNotEmpty
              ? 0
              : null,
          isSubmitting: false,
        ),
      ));
    } catch (e) {
      emit(SurveyError(message: 'Failed to load survey: ${e.toString()}'));
    }
  }

  Future<void> _onAnswerQuestion(
    AnswerQuestion event,
    Emitter<SurveyState> emit,
  ) async {
    if (state is SurveyLoaded) {
      final currentState = state as SurveyLoaded;
      final survey = currentState.data.survey;
      final currentSectionIndex = currentState.data.currentSectionIndex;

      if (currentSectionIndex >= survey.sections.length) return;

      final currentSection = survey.sections[currentSectionIndex];
      final questionIndex = currentSection.questions.indexWhere(
        (q) => q.id == event.questionId,
      );

      if (questionIndex == -1) return;

      final question = currentSection.questions[questionIndex];

      // Update response
      final updatedSurveyResponse = currentState.data.surveyResponse;
      final questionResponse =
          updatedSurveyResponse.questionResponses[event.questionId]!;

      questionResponse.value = event.value;

      // Validate the answer
      final validationResult = _validateQuestionResponse(
        question,
        questionResponse,
        updatedSurveyResponse,
      );

      questionResponse.isValid = validationResult.isValid;
      questionResponse.validationMessage = validationResult.message;

      updatedSurveyResponse.updatedAt = DateTime.now();

      emit(SurveyLoaded(
        data: currentState.data.copyWith(
          surveyResponse: updatedSurveyResponse,
          currentQuestionIndex: questionIndex,
        ),
      ));

      // Auto-navigate to next question if current answer is valid
      // if (validationResult.isValid) {
      //   add(NavigateToNextQuestion());
      // }
    }
  }

  ValidationResult _validateQuestionResponse(
    Question question,
    QuestionResponse response,
    SurveyResponse surveyResponse,
  ) {
    if (question.validationRules == null || question.validationRules!.isEmpty) {
      return ValidationResult(isValid: true);
    }

    for (final rule in question.validationRules!) {
      // Required validation
      if (rule.type == 'required') {
        if (response.value == null ||
            (response.value is String && (response.value as String).isEmpty) ||
            (response.value is List && (response.value as List).isEmpty)) {
          return ValidationResult(
            isValid: false,
            message: rule.message ?? 'This field is required',
          );
        }
      }

      // Dependency validation
      else if (rule.type == 'dependency' && rule.dependsOnQuestionId != null) {
        final dependencyResponse =
            surveyResponse.questionResponses[rule.dependsOnQuestionId!];

        if (dependencyResponse != null &&
            rule.dependsOnValue == dependencyResponse.value &&
            !_evaluateDependencyCondition(rule.condition, response.value)) {
          return ValidationResult(
            isValid: false,
            message: rule.message ??
                'This answer is not compatible with previous answers',
          );
        }
      }
    }

    return ValidationResult(isValid: true);
  }

  bool _evaluateDependencyCondition(dynamic condition, dynamic value) {
    // Simple implementation for demonstration
    // In a real app, you'd have a more sophisticated way to evaluate conditions
    if (condition is Map<String, dynamic>) {
      if (condition.containsKey('min') && value is num) {
        return value >= condition['min'];
      }
      if (condition.containsKey('max') && value is num) {
        return value <= condition['max'];
      }
      if (condition.containsKey('equal')) {
        return value == condition['equal'];
      }
      if (condition.containsKey('notEqual')) {
        return value != condition['notEqual'];
      }
    }
    return true;
  }

  void _onNavigateToNextQuestion(
    NavigateToNextQuestion event,
    Emitter<SurveyState> emit,
  ) {
    if (state is SurveyLoaded) {
      final currentState = state as SurveyLoaded;
      final survey = currentState.data.survey;
      final currentSectionIndex = currentState.data.currentSectionIndex;

      if (currentSectionIndex >= survey.sections.length) return;

      final currentSection = survey.sections[currentSectionIndex];
      final currentQuestionIndex = currentState.data.currentQuestionIndex ?? -1;

      // If we're not at the last question in the section
      if (currentQuestionIndex < currentSection.questions.length - 1) {
        emit(SurveyLoaded(
            data: currentState.data.copyWith(
          currentQuestionIndex: currentQuestionIndex + 1,
        )));
      }
      // If we're at the last question and not the last section
      else if (currentSectionIndex < survey.sections.length - 1) {
        // Save the current section data before navigating
        add(SaveSectionData(currentSectionIndex));

        // Navigate to the first question of the next section
        emit(SurveyLoaded(
            data: currentState.data.copyWith(
          currentSectionIndex: currentSectionIndex + 1,
          currentQuestionIndex: 0,
        )));
      }
    }
  }

  void _onNavigateToPreviousQuestion(
    NavigateToPreviousQuestion event,
    Emitter<SurveyState> emit,
  ) {
    if (state is SurveyLoaded) {
      final currentState = state as SurveyLoaded;
      final survey = currentState.data.survey;
      final currentSectionIndex = currentState.data.currentSectionIndex;

      if (currentSectionIndex >= survey.sections.length) return;

      final currentQuestionIndex = currentState.data.currentQuestionIndex ?? 0;

      // If we're not at the first question in the section
      if (currentQuestionIndex > 0) {
        emit(SurveyLoaded(
            data: currentState.data.copyWith(
          currentQuestionIndex: currentQuestionIndex - 1,
        )));
      }
      // If we're at the first question and not the first section
      else if (currentSectionIndex > 0) {
        final previousSection = survey.sections[currentSectionIndex - 1];
        emit(SurveyLoaded(
            data: currentState.data.copyWith(
          currentSectionIndex: currentSectionIndex - 1,
          currentQuestionIndex: previousSection.questions.length - 1,
        )));
      }
    }
  }

  void _onNavigateToQuestion(
    NavigateToQuestion event,
    Emitter<SurveyState> emit,
  ) {
    if (state is SurveyLoaded) {
      final currentState = state as SurveyLoaded;
      final survey = currentState.data.survey;

      if (event.sectionIndex < 0 ||
          event.sectionIndex >= survey.sections.length) {
        return;
      }

      final targetSection = survey.sections[event.sectionIndex];
      if (event.questionIndex < 0 ||
          event.questionIndex >= targetSection.questions.length) {
        return;
      }

      // If changing sections, save the current section
      if (event.sectionIndex != currentState.data.currentSectionIndex) {
        add(SaveSectionData(currentState.data.currentSectionIndex));
      }

      emit(SurveyLoaded(
          data: currentState.data.copyWith(
        currentSectionIndex: event.sectionIndex,
        currentQuestionIndex: event.questionIndex,
      )));
    }
  }

  void _onNavigateToSection(
    NavigateToSection event,
    Emitter<SurveyState> emit,
  ) {
    if (state is SurveyLoaded) {
      final currentState = state as SurveyLoaded;
      final survey = currentState.data.survey;

      if (event.sectionIndex < 0 ||
          event.sectionIndex >= survey.sections.length) {
        return;
      }

      // Save the current section data before navigating
      add(SaveSectionData(currentState.data.currentSectionIndex));

      emit(SurveyLoaded(
          data: currentState.data.copyWith(
        currentSectionIndex: event.sectionIndex,
        currentQuestionIndex:
            0, // Start at the first question of the new section
      )));
    }
  }

  Future<void> _onSaveSectionData(
    SaveSectionData event,
    Emitter<SurveyState> emit,
  ) async {
    if (state is SurveyLoaded) {
      final currentState = state as SurveyLoaded;
      final survey = currentState.data.survey;

      if (event.sectionIndex < 0 ||
          event.sectionIndex >= survey.sections.length) {
        return;
      }

      final section = survey.sections[event.sectionIndex];
      final updatedSurveyResponse = currentState.data.surveyResponse;

      // Check if all required questions in the section are answered and valid
      // bool isComplete = true;
      // for (final question in section.questions) {
      //   final hasRequiredRule = question.validationRules?.any(
      //         (rule) => rule.type == 'required',
      //       ) ??
      //       false;

      //   final response = updatedSurveyResponse.questionResponses[question.id]!;

      //   if (hasRequiredRule && !response.isValid) {
      //     isComplete = false;
      //     break;
      //   }
      // }

      try {
        // Save only relevant question responses for this section
        final Map<String, QuestionResponse> sectionResponses = {
          for (final question in section.questions)
            question.id: updatedSurveyResponse.questionResponses[question.id]!,
        };

        await _surveyRepository.saveSectionResponse(
          updatedSurveyResponse.surveyId,
          section.id,
          sectionResponses,
        );

        updatedSurveyResponse.updatedAt = DateTime.now();

        emit(SurveyLoaded(
          data: currentState.data.copyWith(
            surveyResponse: updatedSurveyResponse,
          ),
        ));
      } catch (e) {
        emit(SurveyError(
            message: 'Failed to save section data: ${e.toString()}'));
      }
    }
  }

  void _onValidateSurvey(
    ValidateSurvey event,
    Emitter<SurveyState> emit,
  ) {
    if (state is SurveyLoaded) {
      final currentState = state as SurveyLoaded;
      final survey = currentState.data.survey;
      final surveyResponse = currentState.data.surveyResponse;

      bool isValid = true;
      int? firstInvalidSectionIndex;
      int? firstInvalidQuestionIndex;

      for (int sectionIndex = 0;
          sectionIndex < survey.sections.length;
          sectionIndex++) {
        final section = survey.sections[sectionIndex];

        for (int questionIndex = 0;
            questionIndex < section.questions.length;
            questionIndex++) {
          final question = section.questions[questionIndex];
          final response = surveyResponse.questionResponses[question.id]!;

          final hasRequiredRule = question.validationRules?.any(
                (rule) => rule.type == 'required',
              ) ??
              false;

          if (hasRequiredRule && !response.isValid) {
            isValid = false;
            if (firstInvalidSectionIndex == null) {
              firstInvalidSectionIndex = sectionIndex;
              firstInvalidQuestionIndex = questionIndex;
            }
          }
        }
      }

      if (!isValid &&
          firstInvalidSectionIndex != null &&
          firstInvalidQuestionIndex != null) {
        emit(SurveyLoaded(
          data: currentState.data.copyWith(
            currentSectionIndex: firstInvalidSectionIndex,
            currentQuestionIndex: firstInvalidQuestionIndex,
          ),
        ));
      }
    }
  }

  Future<void> _onSubmitSurvey(
    SubmitSurvey event,
    Emitter<SurveyState> emit,
  ) async {
    if (state is SurveyLoaded) {
      final currentState = state as SurveyLoaded;

      // Validate the survey first
      add(ValidateSurvey());

      // After dispatching the validation, we need to allow it to take effect
      await Future.delayed(Duration.zero); // give it a cycle

      final surveyResponse = currentState.data.surveyResponse;
      final survey = currentState.data.survey;

      // Check for completeness: all required questions must be valid
      bool hasIncomplete = false;

      for (final section in survey.sections) {
        for (final question in section.questions) {
          final hasRequiredRule = question.validationRules?.any(
                (rule) => rule.type == 'required',
              ) ??
              false;

          final response = surveyResponse.questionResponses[question.id]!;

          if (hasRequiredRule && !response.isValid) {
            hasIncomplete = true;
            break;
          }
        }
        if (hasIncomplete) break;
      }

      if (hasIncomplete) return;

      emit(SurveyLoaded(
        data: currentState.data.copyWith(isSubmitting: true),
      ));

      try {
        final submittedResponse =
            await _surveyRepository.submitSurvey(surveyResponse);
        emit(SurveySubmitted(submittedResponse));
      } catch (e) {
        emit(SurveyError(message: 'Failed to submit survey: ${e.toString()}'));
      }
    }
  }
}
