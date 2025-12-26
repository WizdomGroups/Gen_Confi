// FILE: lib/features/client/grooming/history/grooming_history_screen.dart

import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/layout/responsive_container.dart';

class GroomingHistoryScreen extends StatelessWidget {
  const GroomingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'History',
      showBackButton: true,
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHistoryCard(
                  title: 'Morning Skincare',
                  date: 'Today, 8:30 AM',
                  status: 'Completed',
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                _buildHistoryCard(
                  title: 'Night Skincare',
                  date: 'Yesterday, 10:15 PM',
                  status: 'Completed',
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                _buildHistoryCard(
                  title: 'Beard Trim',
                  date: 'Yesterday, 8:00 AM',
                  status: 'Skipped',
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildHistoryCard(
                  title: 'Morning Skincare',
                  date: 'Mon, 8:45 AM',
                  status: 'Completed',
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String date,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
