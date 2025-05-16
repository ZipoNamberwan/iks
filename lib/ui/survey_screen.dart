import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iks/model/response/question_response.dart';
import 'package:iks/model/survey/question.dart';
import 'package:iks/ui/question_widget.dart';
import '../bloc/survey_bloc.dart';
import '../bloc/survey_event.dart';
import '../bloc/survey_state.dart';

class SurveyScreen extends StatefulWidget {
  final String surveyId;

  const SurveyScreen({
    super.key,
    required this.surveyId,
  });

  @override
  SurveyScreenState createState() => SurveyScreenState();
}

class SurveyScreenState extends State<SurveyScreen> {
  // ScrollController to detect scroll direction
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;

  @override
  void initState() {
    super.initState();
    // Load the survey when the screen initializes
    context.read<SurveyBloc>().add(LoadSurvey(widget.surveyId));

    // Add scroll listener to hide/sho  w AppBar
    _scrollController.addListener(_listenToScrollChange);
  }

  void _listenToScrollChange() {
    final bool shouldBeVisible =
        _scrollController.position.userScrollDirection ==
                ScrollDirection.forward ||
            _scrollController.offset <= 0;

    if (shouldBeVisible != _isAppBarVisible) {
      setState(() {
        _isAppBarVisible = shouldBeVisible;
      });
    }
  }

  @override
  void dispose() {
    // Dispose of scroll controller
    _scrollController.removeListener(_listenToScrollChange);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SurveyBloc, SurveyState>(
      listener: (context, state) {
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is SurveyLoaded) {
          final survey = state.data.survey;
          final currentSectionIndex = state.data.currentSectionIndex;

          if (currentSectionIndex >= survey.sections.length) {
            return const Scaffold(
              body: Center(child: Text('No sections available')),
            );
          }

          final currentSection = survey.sections[currentSectionIndex];
          final sectionResponse =
              state.data.surveyResponse.sectionResponses[currentSection.id]!;

          return Scaffold(
            // AppBar that shows/hides based on scroll
            appBar: _isAppBarVisible
                ? AppBar(
                    title: Text(survey.title),
                    elevation: 0,
                  )
                : null,
            body: Column(
              children: [
                // Always visible section navigation bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  color: Theme.of(context).primaryColor.withAlpha(25),
                  child: SafeArea(
                    // Ensures content is below status bar
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          survey.sections.length,
                          (index) {
                            final isActive = index == currentSectionIndex;
                            final isComplete = state
                                .data
                                .surveyResponse
                                .sectionResponses[survey.sections[index].id]!
                                .isComplete;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                backgroundColor: isActive
                                    ? Theme.of(context).primaryColor
                                    : isComplete
                                        ? const Color.fromRGBO(
                                            100, 221, 23, 0.2)
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
                  ),
                ),

                // Questions
                Expanded(
                  child: currentSection.questions.isNotEmpty
                      ? SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: currentSection.questions.map((question) {
                              final response =
                                  sectionResponse.responses[question.id];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _buildQuestionCard(
                                  context,
                                  question,
                                  response!,
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : const Center(
                          child: Text('No questions in this section'),
                        ),
                ),

                // Section navigation buttons
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous section button
                        Expanded(
                          flex: 2,
                          child: TextButton.icon(
                            onPressed: currentSectionIndex > 0
                                ? () {
                                    context.read<SurveyBloc>().add(
                                        NavigateToSection(
                                            currentSectionIndex - 1));
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Prev'),
                          ),
                        ),

                        // Section progress indicator
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Section ${currentSectionIndex + 1}/${survey.sections.length}',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Next section button
                        Expanded(
                          flex: 2,
                          child: TextButton.icon(
                            onPressed:
                                currentSectionIndex < survey.sections.length - 1
                                    ? () {
                                        // This will automatically save the current section data
                                        // before navigating, as implemented in your bloc
                                        context.read<SurveyBloc>().add(
                                            NavigateToSection(
                                                currentSectionIndex + 1));
                                      }
                                    : () {
                                        // If we're at the last section, submit the survey
                                        context
                                            .read<SurveyBloc>()
                                            .add(SubmitSurvey());
                                      },
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                                currentSectionIndex < survey.sections.length - 1
                                    ? 'Next'
                                    : 'Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text('Something went wrong')),
        );
      },
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    Question question,
    QuestionResponse response,
  ) {
    return Card(
      elevation: 2,
      key: ObjectKey(question.id), // Add key for Scrollable.ensureVisible
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.text,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (question.hint != null)
              Text(
                question.hint!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 16),
            QuestionWidget(
              question: question,
              response: response,
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
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
