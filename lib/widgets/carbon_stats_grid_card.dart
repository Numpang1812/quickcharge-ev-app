import 'package:flutter/material.dart';

class CarbonStatsGridCard extends StatelessWidget {
  const CarbonStatsGridCard({super.key});

  Widget buildCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        buildCard("Today", "30 kg"),
        buildCard("Week", "120 kg"),
        buildCard("Month", "450 kg"),
        buildCard("Saved", "80 kg"),
      ],
    );
  }
}