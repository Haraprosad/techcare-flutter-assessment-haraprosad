import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/widgets/recent_transactions_list.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/widgets/spending_overview.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  BalanceCard(),
                  const SizedBox(height: 24),
                  SpendingOverview(),
                  const SizedBox(height: 24),
                  _buildRecentTransactionsHeader(),
                ],
              ),
            ),
          ),
          RecentTransactionsList(),
        ],
      ),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'TechCare Finance',
          style: TextStyle(color: Colors.black87),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
      actions: [
        badges.Badge(
          position: badges.BadgePosition.topEnd(top: 8, end: 8),
          badgeContent: const Text('3', style: TextStyle(color: Colors.white)),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person_outline),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: () {}, child: const Text('View All')),
      ],
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      activeBackgroundColor: Colors.grey,
      activeForegroundColor: Colors.white,
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      elevation: 8.0,
      shape: const CircleBorder(),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.arrow_upward),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          label: 'Add Income',
          onTap: () {},
        ),
        SpeedDialChild(
          child: const Icon(Icons.arrow_downward),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          label: 'Add Expense',
          onTap: () {},
        ),
      ],
    );
  }
}
