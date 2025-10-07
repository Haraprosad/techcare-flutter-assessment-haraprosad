import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index >= 10) return null;
        return Dismissible(
          key: Key('transaction_$index'),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16.w),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.blue,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16.w),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                index % 2 == 0 ? Icons.shopping_bag : Icons.fastfood,
                color: index % 2 == 0 ? Colors.blue : Colors.orange,
              ),
            ),
            title: Text(
              index % 2 == 0 ? 'Shopping' : 'Food & Dining',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Oct ${6 - index}, 2025',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Text(
              index % 2 == 0 ? '-\$45.00' : '-\$28.50',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}


