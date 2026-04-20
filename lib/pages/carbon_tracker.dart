import 'package:flutter/material.dart';
import 'package:quickcharge_ev_app/theme/app_colors.dart';


import 'package:quickcharge_ev_app/widgets/carbon_chart_card.dart';
import 'package:quickcharge_ev_app/widgets/carbon_insights_card.dart';
import 'package:quickcharge_ev_app/widgets/carbon_stats_grid_card.dart';
import 'package:quickcharge_ev_app/widgets/carbon_tab_selector.dart';

class CarbonTrackerScreen extends StatefulWidget {
  const CarbonTrackerScreen({super.key});

  @override
  State<CarbonTrackerScreen> createState() => _CarbonTrackerScreenState();
}

class _CarbonTrackerScreenState extends State<CarbonTrackerScreen> {
  String selectedTab = 'Weekly';
  DateTime selectedDate = DateTime.now();

  final List<double> weeklyValues = [30, 18, 46, 30, 60, 12, 0];
  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String get formattedDate {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 16),

              CarbonTabSelector(
                selectedTab: selectedTab,
                onChanged: (value) {
                  setState(() {
                    selectedTab = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              CarbonChartCard(
                values: weeklyValues,
                days: weekDays,
              ),

              const SizedBox(height: 16),

              const CarbonStatsGridCard(),

              const SizedBox(height: 16),

              const CarbonInsightsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Carbon Tracker',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Environmental impact overview',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                formattedDate,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: _pickDate,
          child: const CircleAvatar(
            backgroundColor: AppColors.white,
            child: Icon(Icons.calendar_today),
          ),
        ),
      ],
    );
  }
}