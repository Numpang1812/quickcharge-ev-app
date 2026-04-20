// ignore_for_file: unused_element

import 'package:flutter/material.dart';

import 'calculator.dart';
import 'carbon_tracker.dart';
import 'map.dart';
import 'profile.dart';

class TabbedHomeScreen extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  const TabbedHomeScreen({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    final pages = [
      const MapScreen(),
      const CalculatorScreen(),
      const CarbonTrackerScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom Navigation Bar
// ---------------------------------------------------------------------------

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItemData(icon: Icons.map_outlined, label: 'MAP'),
    _NavItemData(icon: Icons.calculate_outlined, label: 'CALCULATORS'),
    _NavItemData(icon: Icons.bar_chart_outlined, label: 'TRACKER'),
    _NavItemData(icon: Icons.person_outline, label: 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = i == currentIndex;
              final color = isActive
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF94A3B8);
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 24, color: color),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}

// Tracker tab now uses CarbonTrackerScreen from carbon_tracker.dart

// ---------------------------------------------------------------------------
// Friend's additional widgets (kept for completeness)
// ---------------------------------------------------------------------------

class _CalculatorsPage extends StatelessWidget {
  const _CalculatorsPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _PageHeader(title: 'Calculators', icon: Icons.calculate_outlined),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _CalculatorCard(
                    icon: Icons.bolt,
                    title: 'Charging Cost',
                    subtitle: 'Estimate cost per charge session',
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 12),
                  _CalculatorCard(
                    icon: Icons.route,
                    title: 'Range Estimator',
                    subtitle: 'Calculate trip range & stops needed',
                    color: const Color(0xFF22C55E),
                  ),
                  const SizedBox(height: 12),
                  _CalculatorCard(
                    icon: Icons.savings_outlined,
                    title: 'Savings vs Gas',
                    subtitle: 'Compare EV vs gas fuel costs',
                    color: const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _CalculatorCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackerStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TrackerStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final String location;
  final String date;
  final String kwh;
  final String cost;

  const _SessionRow({
    required this.location,
    required this.date,
    required this.kwh,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFDCEAFB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.bolt, color: Color(0xFF2563EB), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '$date · $kwh',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        Text(
          cost,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared page header
// ---------------------------------------------------------------------------

class _PageHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PageHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
