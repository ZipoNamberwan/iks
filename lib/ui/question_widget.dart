import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iks/model/response/survey_response.dart';
import 'package:iks/model/survey/survey.dart';
import 'package:iks/model/survey/question_type.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final QuestionResponse response;
  final FocusNode focusNode;
  final Function(dynamic) onAnswered;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.response,
    required this.focusNode,
    required this.onAnswered,
  }) : super(key: key);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  // Controllers for text and number inputs
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.response.value?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(QuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller if the value changed from outside this widget
    if (oldWidget.response.value != widget.response.value) {
      _textController.text = widget.response.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildQuestionByType();
  }

  Widget _buildQuestionByType() {
    switch (widget.question.type) {
      case QuestionType.text:
        return TextField(
          controller: _textController,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: widget.question.hint,
          ),
          onChanged: (value) {
            widget.onAnswered(value);
          },
        );

      case QuestionType.number:
        return TextField(
          controller: _textController,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: widget.question.hint,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            widget.onAnswered(value.isEmpty ? null : int.parse(value));
          },
        );

      case QuestionType.checkbox:
        return _buildCheckboxGroup();

      case QuestionType.radio:
        return _buildRadioGroup();

      case QuestionType.dropdown:
        return _buildDropdown();

      case QuestionType.date:
        return _buildDatePicker();

      default:
        return Text('Unsupported question type: ${widget.question.type}');
    }
  }

  Widget _buildCheckboxGroup() {
    final options = widget.question.options ?? [];
    final selectedValues = (widget.response.value as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        return CheckboxListTile(
          title: Text(option.label),
          value: selectedValues.contains(option.value),
          onChanged: (selected) {
            final List<dynamic> updatedValues = List.from(selectedValues);

            if (selected ?? false) {
              if (!updatedValues.contains(option.value)) {
                updatedValues.add(option.value);
              }
            } else {
              updatedValues.remove(option.value);
            }

            widget.onAnswered(updatedValues);
          },
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        );
      }).toList(),
    );
  }

  Widget _buildRadioGroup() {
    final options = widget.question.options ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        return RadioListTile<dynamic>(
          title: Text(option.label),
          value: option.value,
          groupValue: widget.response.value,
          onChanged: (value) {
            widget.onAnswered(value);
          },
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        );
      }).toList(),
    );
  }

  Widget _buildDropdown() {
    final options = widget.question.options ?? [];

    return DropdownButtonFormField<dynamic>(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: widget.question.hint,
      ),
      value: widget.response.value,
      items: options.map((option) {
        return DropdownMenuItem(
          value: option.value,
          child: Text(option.label),
        );
      }).toList(),
      onChanged: (value) {
        widget.onAnswered(value);
      },
      focusNode: widget.focusNode,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: widget.response.value != null
              ? DateTime.parse(widget.response.value)
              : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (picked != null) {
          widget.onAnswered(picked.toIso8601String().split('T')[0]);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: widget.question.hint ?? 'Select a date',
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.response.value != null
                  ? _formatDate(widget.response.value)
                  : widget.question.hint ?? 'Select a date',
              style: TextStyle(
                color: widget.response.value != null
                    ? Colors.black
                    : Colors.grey[600],
              ),
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.month}/${date.day}/${date.year}';
  }
}
