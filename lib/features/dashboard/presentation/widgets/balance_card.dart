import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/balance_summary.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:techcare_assessment_app/core/widgets/responsive_layout_builder.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleVisibility(BuildContext context, bool currentVisibility) {
    if (currentVisibility) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    context.read<DashboardBloc>().add(const ToggleBalanceVisibilityEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final balanceSummary = state.balanceSummary;

        if (balanceSummary == null) {
          return _buildSkeletonCard();
        }

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildGlassmorphicCard(context, state, balanceSummary),
        );
      },
    );
  }

  Widget _buildGlassmorphicCard(
    BuildContext context,
    DashboardState state,
    BalanceSummary balanceSummary,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 20.r,
            offset: Offset(0, 10.h), // Responsive shadow offset
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(24.w),
            child: _buildCardContent(context, state, balanceSummary),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    DashboardState state,
    BalanceSummary balanceSummary,
  ) {
    final theme = Theme.of(context);
    final cardTextColor = theme.colorScheme.onPrimary;
    final cardSubtleColor = theme.colorScheme.onPrimary.withOpacity(0.7);
    final isVisible = state.isBalanceVisible;

    // Use adaptive layout for better tablet and landscape support
    return OrientationLayoutBuilder(
      portrait: _buildPortraitContent(
        context,
        cardTextColor,
        cardSubtleColor,
        isVisible,
        balanceSummary,
      ),
      landscape: _buildLandscapeContent(
        context,
        cardTextColor,
        cardSubtleColor,
        isVisible,
        balanceSummary,
      ),
    );
  }

  Widget _buildPortraitContent(
    BuildContext context,
    Color cardTextColor,
    Color cardSubtleColor,
    bool isVisible,
    BalanceSummary balanceSummary,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                color: cardTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: cardTextColor,
              ),
              onPressed: () => _toggleVisibility(context, isVisible),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          isVisible
              ? _currencyFormat.format(balanceSummary.totalBalance)
              : '• • • • • •',
          style: TextStyle(
            color: cardTextColor,
            fontSize: 36.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildBalanceItem(
                icon: Icons.arrow_upward,
                label: 'Monthly Income',
                amount: isVisible
                    ? _currencyFormat.format(balanceSummary.monthlyIncome)
                    : '• • • • • •',
                color: Colors.green,
                textColor: cardTextColor,
                subtleColor: cardSubtleColor,
              ),
            ),
            Container(
              width: 1.w,
              height: 40.h,
              color: cardTextColor.withOpacity(0.2),
            ),
            Expanded(
              child: _buildBalanceItem(
                icon: Icons.arrow_downward,
                label: 'Monthly Expense',
                amount: isVisible
                    ? _currencyFormat.format(balanceSummary.monthlyExpense)
                    : '• • • • • •',
                color: Colors.red,
                textColor: cardTextColor,
                subtleColor: cardSubtleColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLandscapeContent(
    BuildContext context,
    Color cardTextColor,
    Color cardSubtleColor,
    bool isVisible,
    BalanceSummary balanceSummary,
  ) {
    // Landscape: horizontal layout for more efficient space usage
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  color: cardTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                isVisible
                    ? _currencyFormat.format(balanceSummary.totalBalance)
                    : '• • • • • •',
                style: TextStyle(
                  color: cardTextColor,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: cardTextColor,
          ),
          onPressed: () => _toggleVisibility(context, isVisible),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildBalanceItem(
                  icon: Icons.arrow_upward,
                  label: 'Income',
                  amount: isVisible
                      ? _currencyFormat.format(balanceSummary.monthlyIncome)
                      : '• • • • •',
                  color: Colors.green,
                  textColor: cardTextColor,
                  subtleColor: cardSubtleColor,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildBalanceItem(
                  icon: Icons.arrow_downward,
                  label: 'Expense',
                  amount: isVisible
                      ? _currencyFormat.format(balanceSummary.monthlyExpense)
                      : '• • • • •',
                  color: Colors.red,
                  textColor: cardTextColor,
                  subtleColor: cardSubtleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
    required Color textColor,
    required Color subtleColor,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            color: subtleColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          amount,
          style: TextStyle(
            color: textColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
        ),
      ),
    );
  }
}
