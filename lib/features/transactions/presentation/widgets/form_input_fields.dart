import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

/// Form field for title input with throttled onChange
class TitleInputField extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  final String? errorText;
  final bool enabled;

  const TitleInputField({
    Key? key,
    this.initialValue = '',
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<TitleInputField> createState() => _TitleInputFieldState();
}

class _TitleInputFieldState extends State<TitleInputField> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    // Debounce to 300ms to reduce BLoC event spam while typing
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      initialValue: widget.initialValue,
      enabled: widget.enabled,
      maxLength: 100,
      decoration: InputDecoration(
        labelText: 'Title *',
        hintText: 'Enter transaction title',
        errorText: widget.errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      onChanged: _onTextChanged,
    );
  }
}

/// Form field for description input with throttled onChange
class DescriptionInputField extends StatefulWidget {
  final String? initialValue;
  final Function(String?) onChanged;
  final String? errorText;
  final bool enabled;

  const DescriptionInputField({
    Key? key,
    this.initialValue,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<DescriptionInputField> createState() => _DescriptionInputFieldState();
}

class _DescriptionInputFieldState extends State<DescriptionInputField> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    // Debounce to 300ms to reduce BLoC event spam while typing
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged(value.isEmpty ? null : value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      initialValue: widget.initialValue,
      enabled: widget.enabled,
      maxLength: 500,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Add notes about this transaction',
        errorText: widget.errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surface,
        alignLabelWithHint: true,
      ),
      onChanged: _onTextChanged,
    );
  }
}

/// Date picker field
class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final String? errorText;
  final bool enabled;

  const DatePickerField({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select Transaction Date',
    );

    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return InkWell(
      onTap: enabled ? () => _selectDate(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date *',
          errorText: errorText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.colorScheme.surface,
          suffixIcon: Icon(
            Icons.calendar_today,
            color: theme.colorScheme.primary,
          ),
        ),
        child: Text(
          dateFormat.format(selectedDate),
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

/// Time picker field (optional)
class TimePickerField extends StatelessWidget {
  final DateTime? selectedTime;
  final Function(DateTime?) onTimeSelected;
  final bool enabled;

  const TimePickerField({
    Key? key,
    this.selectedTime,
    required this.onTimeSelected,
    this.enabled = true,
  }) : super(key: key);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = selectedTime != null
        ? TimeOfDay.fromDateTime(selectedTime!)
        : TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Select Transaction Time',
    );

    if (picked != null) {
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      onTimeSelected(dateTime);
    }
  }

  void _clearTime() {
    onTimeSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('hh:mm a');

    return InkWell(
      onTap: enabled ? () => _selectTime(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Time (Optional)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.colorScheme.surface,
          suffixIcon: selectedTime != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: enabled ? _clearTime : null,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                )
              : Icon(Icons.access_time, color: theme.colorScheme.primary),
        ),
        child: Text(
          selectedTime != null
              ? timeFormat.format(selectedTime!)
              : 'Select time',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: selectedTime != null
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
