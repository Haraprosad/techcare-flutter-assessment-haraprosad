import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:techcare_assessment_app/core/di/injection.dart';
import 'package:techcare_assessment_app/core/utils/snackbar_utils.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/bloc/transaction_form_bloc.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/amount_input_field.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/category_selector.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/form_input_fields.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/transaction_type_selector.dart';

/// Add/Edit Transaction Screen with form validation and submission
class AddEditTransactionScreen extends StatelessWidget {
  final Transaction? transaction; // null for add, Transaction for edit
  final TransactionType?
  initialType; // Initial transaction type (income/expense)

  const AddEditTransactionScreen({Key? key, this.transaction, this.initialType})
    : super(key: key);

  bool get isEditMode => transaction != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = sl<TransactionFormBloc>();
        if (transaction != null) {
          bloc.add(InitializeFormWithTransactionEvent(transaction!));
        } else {
          bloc.add(const InitializeFormEvent());
          // Set initial type if provided
          if (initialType != null) {
            bloc.add(UpdateTypeEvent(initialType!));
          }
        }
        return bloc;
      },
      child: _AddEditTransactionView(isEditMode: isEditMode),
    );
  }
}

class _AddEditTransactionView extends StatelessWidget {
  final bool isEditMode;

  const _AddEditTransactionView({Key? key, required this.isEditMode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionFormBloc, TransactionFormState>(
      listener: (context, state) {
        // Handle success
        if (state.savedTransaction != null) {
          SnackbarUtils.showSuccess(
            context,
            isEditMode
                ? 'Transaction updated successfully'
                : 'Transaction created successfully',
          );
          context.pop(true); // Return true to indicate success
        }

        // Handle error
        if (state.failure != null) {
          SnackbarUtils.showError(context, state.failure!.translatedMessage);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Transaction' : 'Add Transaction'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleCancel(context),
          ),
        ),
        body: BlocBuilder<TransactionFormBloc, TransactionFormState>(
          builder: (context, state) {
            if (state.categoriesLoading && state.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount Input
                  AmountInputField(
                    initialAmount: state.formData.amount,
                    onAmountChanged: (amount) {
                      context.read<TransactionFormBloc>().add(
                        UpdateAmountEvent(amount),
                      );
                    },
                    errorText: state.getFieldError('amount'),
                    enabled: !state.isSubmitting,
                  ),
                  SizedBox(height: 24.h),

                  // Transaction Type Selector
                  TransactionTypeSelector(
                    selectedType: state.formData.type,
                    onTypeChanged: (type) {
                      context.read<TransactionFormBloc>().add(
                        UpdateTypeEvent(type),
                      );
                    },
                    enabled: !state.isSubmitting,
                  ),
                  SizedBox(height: 24.h),

                  // Category Selection
                  CategorySelector(
                    categories: state.categories.where((cat) {
                      // Filter categories based on transaction type
                      // Assuming categories have a 'type' field
                      return true; // You can add filtering logic here
                    }).toList(),
                    selectedCategory: state.formData.category,
                    onCategorySelected: (category) {
                      context.read<TransactionFormBloc>().add(
                        UpdateCategoryEvent(category),
                      );
                    },
                    errorText: state.getFieldError('category'),
                    enabled: !state.isSubmitting,
                  ),
                  SizedBox(height: 24.h),

                  // Title Input
                  TitleInputField(
                    initialValue: state.formData.title,
                    onChanged: (title) {
                      context.read<TransactionFormBloc>().add(
                        UpdateTitleEvent(title),
                      );
                    },
                    errorText: state.getFieldError('title'),
                    enabled: !state.isSubmitting,
                  ),
                  SizedBox(height: 16.h),

                  // Description Input
                  DescriptionInputField(
                    initialValue: state.formData.description,
                    onChanged: (description) {
                      context.read<TransactionFormBloc>().add(
                        UpdateDescriptionEvent(description),
                      );
                    },
                    errorText: state.getFieldError('description'),
                    enabled: !state.isSubmitting,
                  ),
                  SizedBox(height: 16.h),

                  // Date Picker
                  DatePickerField(
                    selectedDate: state.formData.date,
                    onDateSelected: (date) {
                      context.read<TransactionFormBloc>().add(
                        UpdateDateEvent(date),
                      );
                    },
                    errorText: state.getFieldError('date'),
                    enabled: !state.isSubmitting,
                  ),
                  SizedBox(height: 16.h),

                  // Time Picker
                  TimePickerField(
                    selectedTime: state.formData.time,
                    onTimeSelected: (time) {
                      context.read<TransactionFormBloc>().add(
                        UpdateTimeEvent(time),
                      );
                    },
                    enabled: !state.isSubmitting,
                  ),
                  SizedBox(height: 32.h),

                  // Action Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => _handleCancel(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 16.w),

                      // Save Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => _handleSubmit(context),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: state.isSubmitting
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(isEditMode ? 'Update' : 'Save'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleCancel(BuildContext context) {
    // Show confirmation dialog if form has changes
    final state = context.read<TransactionFormBloc>().state;

    if (state.formData.amount != null || state.formData.title.isNotEmpty) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('Are you sure you want to discard your changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Continue Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.pop(false);
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      context.pop(false);
    }
  }

  void _handleSubmit(BuildContext context) {
    context.read<TransactionFormBloc>().add(const SubmitFormEvent());
  }
}
