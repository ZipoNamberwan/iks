import 'package:equatable/equatable.dart';
import 'package:iks/model/response/survey_response.dart';
import 'package:iks/model/survey/survey.dart';

class SurveyState extends Equatable {
  const SurveyState();

  @override
  List<Object> get props => [];
}

class SurveyInitial extends SurveyState {
  const SurveyInitial();
}

class SurveyLoading extends SurveyState {
  const SurveyLoading();
}

class SurveyError extends SurveyState {
  final String message;

  const SurveyError({required this.message});

  @override
  List<Object> get props => [message];
}

class SurveyLoaded extends SurveyState {
  final SurveyStateData data;

  const SurveyLoaded({required this.data});

  @override
  List<Object> get props => [data];
}

class SurveySubmitted extends SurveyState {
  final SurveyResponse response;

  const SurveySubmitted(this.response);

  @override
  List<Object> get props => [response];
}

class SurveyStateData {
  final Survey survey;
  final SurveyResponse surveyResponse;
  final int currentSectionIndex;
  final int? currentQuestionIndex;
  final bool isSubmitting;

  SurveyStateData({
    required this.survey,
    required this.surveyResponse,
    required this.currentSectionIndex,
    this.currentQuestionIndex,
    required this.isSubmitting,
  });

  SurveyStateData copyWith({
    Survey? survey,
    SurveyResponse? surveyResponse,
    int? currentSectionIndex,
    int? currentQuestionIndex,
    bool? isSubmitting,
  }) {
    return SurveyStateData(
      survey: survey ?? this.survey,
      surveyResponse: surveyResponse ?? this.surveyResponse,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
