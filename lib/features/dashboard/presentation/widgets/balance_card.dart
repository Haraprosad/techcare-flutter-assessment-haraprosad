import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/balance_summary.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';

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
          tween: Tween(begin: 0.0, end: 1.0),
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
        borderRadius: BorderRadius.circular(24),
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
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                color: cardTextColor,
                fontSize: 16,
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
        const SizedBox(height: 16),
        Text(
          isVisible
              ? _currencyFormat.format(balanceSummary.totalBalance)
              : '• • • • • •',
          style: TextStyle(
            color: cardTextColor,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBalanceItem(
              icon: Icons.arrow_upward,
              label: 'Monthly Income',
              amount: isVisible
                  ? _currencyFormat.format(balanceSummary.monthlyIncome)
                  : '• • • • • •',
              color: Colors.green,
              textColor: cardTextColor,
              subtleColor: cardSubtleColor,
            ),
            Container(
              width: 1,
              height: 40,
              color: cardTextColor.withOpacity(0.2),
            ),
            _buildBalanceItem(
              icon: Icons.arrow_downward,
              label: 'Monthly Expense',
              amount: isVisible
                  ? _currencyFormat.format(balanceSummary.monthlyExpense)
                  : '• • • • • •',
              color: Colors.red,
              textColor: cardTextColor,
              subtleColor: cardSubtleColor,
            ),
          ],
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: subtleColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
        ),
      ),
    );
  }
}
