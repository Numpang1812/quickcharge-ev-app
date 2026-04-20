import 'package:flutter/material.dart';

class CarbonTabSelector extends StatelessWidget {
  final String selectedTab;
  final Function(String) onChanged;

  const CarbonTabSelector({
    super.key,
    required this.selectedTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['Weekly', 'Monthly'];

    return Row(
      children: tabs.map((tab) {
        final isSelected = selectedTab == tab;

        return GestureDetector(
          onTap: () => onChanged(tab),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tab,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}