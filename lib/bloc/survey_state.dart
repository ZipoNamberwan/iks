import 'package:equatable/equatable.dart';
import 'package:iks/model/response/survey_response.dart';
import 'package:iks/model/survey/survey.dart';

abstract class SurveyState extends Equatable {
  const SurveyState();

  @override
  List<Object?> get props => [];
}

class SurveyInitial extends SurveyState {}

class SurveyLoading extends SurveyState {}

class SurveyLoaded extends SurveyState {
  final Survey survey;
  final SurveyResponse surveyResponse;
  final int currentSectionIndex;
  final int? currentQuestionIndex;
  final bool isSubmitting;

  const SurveyLoaded({
    required this.survey,
    required this.surveyResponse,
    this.currentSectionIndex = 0,
    this.currentQuestionIndex,
    this.isSubmitting = false,
  });

  SurveyLoaded copyWith({
    Survey? survey,
    SurveyResponse? surveyResponse,
    int? currentSectionIndex,
    int? currentQuestionIndex,
    bool? isSubmitting,
  }) {
    return SurveyLoaded(
      survey: survey ?? this.survey,
      surveyResponse: surveyResponse ?? this.surveyResponse,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      currentQuestionIndex: currentQuestionIndex != null
          ? currentQuestionIndex
          : this.currentQuestionIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        survey,
        surveyResponse,
        currentSectionIndex,
        currentQuestionIndex,
        isSubmitting,
      ];
}

class SurveyError extends SurveyState {
  final String message;

  const SurveyError(this.message);

  @override
  List<Object> get props => [message];
}

class SurveySubmitted extends SurveyState {
  final SurveyResponse response;

  const SurveySubmitted(this.response);

  @override
  List<Object> get props => [response];
}