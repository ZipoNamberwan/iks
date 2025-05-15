import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iks/model/response/survey_response.dart';
import 'package:iks/model/survey/survey.dart';
import 'package:iks/ui/question_widget.dart';
import '../bloc/survey_bloc.dart';
import '../bloc/survey_event.dart';
import '../bloc/survey_state.dart';

class SurveyScreen extends StatefulWidget {
  final String surveyId;

  const SurveyScreen({
    Key? key,
    required this.surveyId,
  }) : super(key: key);

  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  // For managing focus and auto-advancing
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    // Load the survey when the screen initializes
    context.read<SurveyBloc>().add(LoadSurvey(widget.surveyId));
  }

  @override
  void dispose() {
    // Dispose of focus nodes
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey'),
      ),
      body: BlocConsumer<SurveyBloc, SurveyState>(
        listener: (context, state) {
          if (state is SurveyLoaded) {
            // Set focus on the current question when it changes
            if (state.currentQuestionIndex != null &&
                state.currentSectionIndex < state.survey.sections.length) {
              final section = state.survey.sections[state.currentSectionIndex];
              if (state.currentQuestionIndex! < section.questions.length) {
                final question = section.questions[state.currentQuestionIndex!];

                // Create focus node if it doesn't exist
                if (!_focusNodes.containsKey(question.id)) {
                  _focusNodes[question.id] = FocusNode();
                }

                // Request focus after a short delay to allow the widget to build
                Future.delayed(Duration(milliseconds: 100), () {
                  if (_focusNodes[question.id]?.canRequestFocus ?? false) {
                    _focusNodes[question.id]?.requestFocus();
                  }
                });
              }
            }
          }

          if (state is SurveyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is SurveySubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Survey submitted successfully!')),
            );
            // Navigate back or to a success screen
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is SurveyInitial || state is SurveyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SurveyLoaded) {
            final survey = state.survey;
            final currentSectionIndex = state.currentSectionIndex;

            if (currentSectionIndex >= survey.sections.length) {
              return const Center(child: Text('No sections available'));
            }

            final currentSection = survey.sections[currentSectionIndex];
            final sectionResponse =
                state.surveyResponse.sectionResponses[currentSection.id]!;

            return Column(
              children: [
                // Section navigation
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        survey.title,
                        // style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 8),

                      // Section tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            survey.sections.length,
                            (index) {
                              final isActive = index == currentSectionIndex;
                              final isComplete = state
                                  .surveyResponse
                                  .sectionResponses[survey.sections[index].id]!
                                  .isComplete;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ActionChip(
                                  backgroundColor: isActive
                                      ? Theme.of(context).primaryColor
                                      : isComplete
                                          ? Colors.green.withOpacity(0.2)
                                          : null,
                                  avatar: isComplete
                                      ? const Icon(Icons.check, size: 16)
                                      : null,
                                  label: Text(
                                    survey.sections[index].title,
                                    style: TextStyle(
                                      color: isActive ? Colors.white : null,
                                    ),
                                  ),
                                  onPressed: () {
                                    context
                                        .read<SurveyBloc>()
                                        .add(NavigateToSection(index));
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Current section info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSection.title,
                        // style: Theme.of(context).textTheme.headline5,
                      ),
                      if (currentSection.description != null)
                        Text(
                          currentSection.description!,
                          // style: Theme.of(context).textTheme.bodyText2,
                        ),
                    ],
                  ),
                ),

                // Questions
                Expanded(
                  child: state.currentQuestionIndex != null &&
                          state.currentQuestionIndex! <
                              currentSection.questions.length
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildQuestionCard(
                            context,
                            currentSection
                                .questions[state.currentQuestionIndex!],
                            sectionResponse.responses[currentSection
                                .questions[state.currentQuestionIndex!].id]!,
                          ),
                        )
                      : const Center(
                          child: Text('No questions in this section')),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      ElevatedButton(
                        onPressed: currentSectionIndex > 0 ||
                                (state.currentQuestionIndex ?? 0) > 0
                            ? () => context
                                .read<SurveyBloc>()
                                .add(NavigateToPreviousQuestion())
                            : null,
                        child: const Text('Previous'),
                      ),

                      // Progress indicator
                      if (state.currentQuestionIndex != null)
                        Text(
                          '${(state.currentQuestionIndex! + 1)} / ${currentSection.questions.length}',
                          // style: Theme.of(context).textTheme.subtitle1,
                        ),

                      // Next/Submit button
                      ElevatedButton(
                        onPressed: () {
                          if (currentSectionIndex ==
                                  survey.sections.length - 1 &&
                              (state.currentQuestionIndex ?? 0) ==
                                  currentSection.questions.length - 1) {
                            // Last question of last section - submit the survey
                            context.read<SurveyBloc>().add(SubmitSurvey());
                          } else {
                            // Move to next question
                            context
                                .read<SurveyBloc>()
                                .add(NavigateToNextQuestion());
                          }
                        },
                        child: Text(
                          currentSectionIndex == survey.sections.length - 1 &&
                                  (state.currentQuestionIndex ?? 0) ==
                                      currentSection.questions.length - 1
                              ? 'Submit'
                              : 'Next',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    Question question,
    QuestionResponse response,
  ) {
    // Create focus node if it doesn't exist
    if (!_focusNodes.containsKey(question.id)) {
      _focusNodes[question.id] = FocusNode();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.text,
              // style: Theme.of(context).textTheme.headline6,
            ),
            if (question.hint != null)
              Text(
                question.hint!,
                // style: Theme.of(context).textTheme.caption,
              ),
            const SizedBox(height: 16),
            QuestionWidget(
              question: question,
              response: response,
              focusNode: _focusNodes[question.id]!,
              onAnswered: (value) {
                context.read<SurveyBloc>().add(
                      AnswerQuestion(
                        questionId: question.id,
                        value: value,
                      ),
                    );
              },
            ),
            if (!response.isValid && response.validationMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  response.validationMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
