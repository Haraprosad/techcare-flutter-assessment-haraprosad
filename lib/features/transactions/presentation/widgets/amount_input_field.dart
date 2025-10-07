import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Custom amount input widget with currency formatting
class AmountInputField extends StatefulWidget {
  final double? initialAmount;
  final Function(double?) onAmountChanged;
  final String? errorText;
  final bool enabled;

  const AmountInputField({
    Key? key,
    this.initialAmount,
    required this.onAmountChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  final TextEditingController _controller = TextEditingController();
  final NumberFormat _currencyFormatter = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _controller.text = _currencyFormatter.format(widget.initialAmount);
    }
  }

  @override
  void didUpdateWidget(AmountInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAmount != oldWidget.initialAmount &&
        widget.initialAmount != null) {
      _controller.text = _currencyFormatter.format(widget.initialAmount);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChange(String value) {
    // Remove formatting characters
    final cleanValue = value.replaceAll(',', '').replaceAll(' ', '');

    if (cleanValue.isEmpty) {
      widget.onAmountChanged(null);
      return;
    }

    // Parse the value
    final parsedValue = double.tryParse(cleanValue);

    if (parsedValue != null) {
      widget.onAmountChanged(parsedValue);

      // Format and update the text field
      final formattedValue = _currencyFormatter.format(parsedValue);

      // Only update if the formatted value is different
      if (_controller.text != formattedValue) {
        _controller.value = TextEditingValue(
          text: formattedValue,
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? theme.colorScheme.error
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: hasError ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Currency symbol
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 8),
                child: Text(
                  '৳',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: widget.enabled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Amount input
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                  ],
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasError
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                  ),
                  onChanged: _handleTextChange,
                ),
              ),
            ],
          ),
        ),

        // Error message
        if (hasError) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
