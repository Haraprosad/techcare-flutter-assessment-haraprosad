import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/balance_summary.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:techcare_assessment_app/core/widgets/responsive_layout_builder.dart';
import 'package:techcare_assessment_app/core/theme/constants/app_spacing.dart';
import 'package:techcare_assessment_app/core/theme/constants/app_sizes.dart';
import 'package:techcare_assessment_app/core/widgets/animated_number_counter.dart';
import 'package:techcare_assessment_app/core/theme/extensions/theme_extensions.dart';
import 'package:techcare_assessment_app/core/localization/extension/loc.dart';

/// Balance Card Widget
///
/// Features:
/// - Glassmorphism design with backdrop blur
/// - 3D flip animation on visibility toggle (600ms, easeInOutCubic)
/// - Animated number transitions (800ms)
/// - Monthly income and expense summary
/// - Responsive layout for portrait/landscape
class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Use success color (green) for dark theme, primary for light theme
    final gradientColor = isDark ? context.colors.success : colorScheme.primary;

    return AnimatedBuilder(
      animation: _flipController,
      builder: (context, child) {
        final angle = _flipController.value * math.pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientColor.withOpacity(0.8),
                  gradientColor.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColor.withOpacity(0.3),
                  blurRadius: 20.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: AppSpacing.lgPadding,
                  child: _buildCardContent(context, state, balanceSummary),
                ),
              ),
            ),
          ),
        );
      },
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.loc.total_balance,
              style: textTheme.titleMedium?.copyWith(
                color: cardTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: cardTextColor,
                size: AppSizes.iconMd,
              ),
              onPressed: () => _toggleVisibility(context, isVisible),
            ),
          ],
        ),
        AppSpacing.mdHeight,
        if (isVisible)
          AnimatedNumberCounter(
            value: balanceSummary.totalBalance,
            prefix: '\$',
            style: textTheme.displaySmall?.copyWith(
              color: cardTextColor,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Text(
            '• • • • • •',
            style: textTheme.displaySmall?.copyWith(
              color: cardTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        AppSpacing.lgHeight,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildBalanceItem(
                context: context,
                icon: Icons.arrow_upward,
                label: context.loc.monthly_income,
                amount: balanceSummary.monthlyIncome,
                isVisible: isVisible,
                color: theme.colorScheme.tertiary,
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
                context: context,
                icon: Icons.arrow_downward,
                label: context.loc.monthly_expense,
                amount: balanceSummary.monthlyExpense,
                isVisible: isVisible,
                color: theme.colorScheme.error,
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.loc.total_balance,
                style: textTheme.titleSmall?.copyWith(
                  color: cardTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppSpacing.smHeight,
              if (isVisible)
                AnimatedNumberCounter(
                  value: balanceSummary.totalBalance,
                  prefix: '\$',
                  style: textTheme.headlineMedium?.copyWith(
                    color: cardTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  '• • • • • •',
                  style: textTheme.headlineMedium?.copyWith(
                    color: cardTextColor,
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
            size: AppSizes.iconMd,
          ),
          onPressed: () => _toggleVisibility(context, isVisible),
        ),
        AppSpacing.mdWidth,
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildBalanceItem(
                  context: context,
                  icon: Icons.arrow_upward,
                  label: context.loc.income,
                  amount: balanceSummary.monthlyIncome,
                  isVisible: isVisible,
                  color: theme.colorScheme.tertiary,
                  textColor: cardTextColor,
                  subtleColor: cardSubtleColor,
                ),
              ),
              AppSpacing.mdWidth,
              Expanded(
                child: _buildBalanceItem(
                  context: context,
                  icon: Icons.arrow_downward,
                  label: context.loc.expense,
                  amount: balanceSummary.monthlyExpense,
                  isVisible: isVisible,
                  color: theme.colorScheme.error,
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required double amount,
    required bool isVisible,
    required Color color,
    required Color textColor,
    required Color subtleColor,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Container(
          padding: AppSpacing.smPadding,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(icon, color: color, size: AppSizes.iconMd),
        ),
        AppSpacing.smHeight,
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: subtleColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpacing.xsHeight,
        if (isVisible)
          AnimatedNumberCounter(
            value: amount,
            prefix: '\$',
            style: textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Text(
            '• • • • •',
            style: textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    final theme = Theme.of(context);
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
