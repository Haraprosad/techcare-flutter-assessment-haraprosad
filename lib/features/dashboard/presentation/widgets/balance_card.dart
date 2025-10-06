import 'dart:ui';
import 'package:flutter/material.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  bool _isBalanceVisible = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildCardContent({required bool isVisible}) {
    final theme = Theme.of(context);
    final cardTextColor = theme.colorScheme.onPrimary;
    final cardSubtleColor = theme.colorScheme.onPrimary.withOpacity(0.7);

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
              onPressed: () {
                setState(() {
                  _isBalanceVisible = !_isBalanceVisible;
                  if (_isBalanceVisible) {
                    _animationController.reverse();
                  } else {
                    _animationController.forward();
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          isVisible ? '\$65,080.00' : '• • • • • •',
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
              amount: isVisible ? '\$118,000' : '• • • • • •',
              color: Colors.green,
              isVisible: isVisible,
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
              amount: isVisible ? '\$52,920' : '• • • • • •',
              color: Colors.red,
              isVisible: isVisible,
              textColor: cardTextColor,
              subtleColor: cardSubtleColor,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final angle = _animationController.value * 3.14;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.9),
                      primaryColor.withOpacity(0.7),
                    ],
                  ),
                  border: Border.all(
                    color: theme.colorScheme.onPrimary.withOpacity(0.2),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: angle < 1.57
                    ? _buildCardContent(isVisible: true)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.14),
                        child: _buildCardContent(isVisible: false),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
    required bool isVisible,
    required Color textColor,
    required Color subtleColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: subtleColor, fontSize: 14)),
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
}
