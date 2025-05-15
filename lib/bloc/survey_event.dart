import 'package:equatable/equatable.dart';

abstract class SurveyEvent extends Equatable {
  const SurveyEvent();

  @override
  List<Object?> get props => [];
}

class LoadSurvey extends SurveyEvent {
  final String surveyId;

  const LoadSurvey(this.surveyId);

  @override
  List<Object> get props => [surveyId];
}

class AnswerQuestion extends SurveyEvent {
  final String questionId;
  final dynamic value;

  const AnswerQuestion({
    required this.questionId,
    required this.value,
  });

  @override
  List<Object?> get props => [questionId, value];
}

class NavigateToNextQuestion extends SurveyEvent {}

class NavigateToPreviousQuestion extends SurveyEvent {}

class NavigateToQuestion extends SurveyEvent {
  final int sectionIndex;
  final int questionIndex;

  const NavigateToQuestion({
    required this.sectionIndex,
    required this.questionIndex,
  });

  @override
  List<Object> get props => [sectionIndex, questionIndex];
}

class NavigateToSection extends SurveyEvent {
  final int sectionIndex;

  const NavigateToSection(this.sectionIndex);

  @override
  List<Object> get props => [sectionIndex];
}

class SaveSectionData extends SurveyEvent {
  final int sectionIndex;

  const SaveSectionData(this.sectionIndex);

  @override
  List<Object> get props => [sectionIndex];
}

class ValidateSurvey extends SurveyEvent {}

class SubmitSurvey extends SurveyEvent {}