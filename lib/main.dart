// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iks/bloc/survey_bloc.dart';
import 'package:iks/repositories/survey_repositories.dart';
import 'ui/survey_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Survey App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RepositoryProvider(
        create: (context) => SurveyRepository(),
        child: BlocProvider(
          create: (context) => SurveyBloc(
            RepositoryProvider.of<SurveyRepository>(context),
          ),
          child: const SurveyScreen(surveyId: 'sample_survey'),
        ),
      ),
    );
  }
}
