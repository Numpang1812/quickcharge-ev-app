import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Quick Estimator state
  final TextEditingController _batteryCapacityController =
      TextEditingController(text: '75');
  double _currentCharge = 0.20;
  double _targetCharge = 0.80;
  double _costPerKwh = 0.13;

  double get _batteryCapacity =>
      double.tryParse(_batteryCapacityController.text) ?? 75;

  double get _kwhNeeded =>
      _batteryCapacity * (_targetCharge - _currentCharge).clamp(0, 1);

  double get _estimatedCost => _kwhNeeded * _costPerKwh;

  @override
  void dispose() {
    _batteryCapacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Charging Calculators',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Estimate your charging needs',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Calculator Cards ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _CalculatorNavCard(
                      icon: Icons.battery_charging_full_outlined,
                      iconBgColor: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF49B63C),
                      title: 'Distance Calculator',
                      subtitle: 'Battery to Range',
                      onTap: () => _showDistanceCalculator(context),
                    ),
                    const SizedBox(height: 12),
                    _CalculatorNavCard(
                      icon: Icons.attach_money,
                      iconBgColor: const Color(0xFFFFFBEB),
                      iconColor: const Color(0xFF49B63C),
                      title: 'Cost Calculator',
                      subtitle: 'Charging Cost Estimator',
                      onTap: () => _showCostCalculator(context),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Quick Estimator ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Estimator',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Battery Capacity input
                      _FieldLabel('BATTERY CAPACITY (KWH)'),
                      const SizedBox(height: 8),
                      _NumberInputField(
                        controller: _batteryCapacityController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),

                      // Current Charge slider
                      _FieldLabel('CURRENT CHARGE (%)'),
                      const SizedBox(height: 4),
                      _SliderRow(
                        value: _currentCharge,
                        min: 0,
                        max: 1,
                        leftLabel: '${(_currentCharge * 100).round()}%',
                        rightLabel: '100%',
                        activeColor: const Color(0xFF49B63C),
                        onChanged: (v) {
                          setState(() {
                            _currentCharge = v;
                            if (_targetCharge <= _currentCharge) {
                              _targetCharge = (_currentCharge + 0.05).clamp(
                                0,
                                1,
                              );
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Target Charge slider
                      _FieldLabel('TARGET CHARGE (%)'),
                      const SizedBox(height: 4),
                      _SliderRow(
                        value: _targetCharge,
                        min: 0,
                        max: 1,
                        leftLabel: '${(_currentCharge * 100).round()}%',
                        rightLabel: '${(_targetCharge * 100).round()}%',
                        activeColor: const Color(0xFF22C55E),
                        onChanged: (v) {
                          setState(() {
                            _targetCharge = v;
                            if (_targetCharge <= _currentCharge) {
                              _currentCharge = (_targetCharge - 0.05).clamp(
                                0,
                                1,
                              );
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Cost per kWh input
                      // _FieldLabel('COST PER KWH (\$)'),
                      // const SizedBox(height: 8),
                      // _NumberInputField(
                      //   controller: TextEditingController(
                      //     text: _costPerKwh.toStringAsFixed(2),
                      //   ),
                      //   onChanged: (v) {
                      //     setState(() {
                      //       _costPerKwh = double.tryParse(v) ?? 0.13;
                      //     });
                      //   },
                      //   prefix: '\$',
                      // ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFF1F5F9), height: 1),
                      const SizedBox(height: 20),

                      // Results
                      Row(
                        children: [
                          Expanded(
                            child: _ResultTile(
                              label: 'Estimated Range',
                              value: '${_kwhNeeded.toStringAsFixed(1)} kWh',
                              icon: Icons.bolt,
                              color: const Color(0xFF49B63C),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ResultTile(
                              label: 'Full Charge Cost',
                              value: '\$${_estimatedCost.toStringAsFixed(2)}',
                              icon: Icons.attach_money,
                              color: const Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ── Distance Calculator Bottom Sheet ──────────────────────────────────────
  void _showDistanceCalculator(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DistanceCalculatorSheet(),
    );
  }

  // ── Cost Calculator Bottom Sheet ──────────────────────────────────────────
  void _showCostCalculator(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CostCalculatorSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Calculator Nav Card
// ---------------------------------------------------------------------------

class _CalculatorNavCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CalculatorNavCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCBD5E1),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.7,
      ),
    );
  }
}

class _NumberInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? prefix;

  const _NumberInputField({
    required this.controller,
    required this.onChanged,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          prefixText: prefix,
          prefixStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String leftLabel;
  final String rightLabel;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.value,
    required this.min,
    required this.max,
    required this.leftLabel,
    required this.rightLabel,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: const Color(0xFFE2E8F0),
            thumbColor: activeColor,
            overlayColor: activeColor.withOpacity(0.12),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leftLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                rightLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ResultTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Distance Calculator Sheet
// ---------------------------------------------------------------------------

class _DistanceCalculatorSheet extends StatefulWidget {
  const _DistanceCalculatorSheet();

  @override
  State<_DistanceCalculatorSheet> createState() =>
      _DistanceCalculatorSheetState();
}

class _DistanceCalculatorSheetState extends State<_DistanceCalculatorSheet> {
  final _capacityCtrl = TextEditingController(text: '75');
  double _chargeLevel = 0.80;
  double _efficiency = 4.0; // miles per kWh

  double get _range =>
      (double.tryParse(_capacityCtrl.text) ?? 75) * _chargeLevel * _efficiency;

  @override
  void dispose() {
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Distance Calculator',
      icon: Icons.battery_charging_full_outlined,
      iconColor: const Color(0xFF2563EB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('BATTERY CAPACITY (KWH)'),
          const SizedBox(height: 8),
          _NumberInputField(
            controller: _capacityCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          _FieldLabel('CURRENT CHARGE LEVEL (%)'),
          const SizedBox(height: 4),
          _SliderRow(
            value: _chargeLevel,
            min: 0,
            max: 1,
            leftLabel: '0%',
            rightLabel: '${(_chargeLevel * 100).round()}%',
            activeColor: const Color(0xFF2563EB),
            onChanged: (v) => setState(() => _chargeLevel = v),
          ),
          const SizedBox(height: 20),
          _FieldLabel('EFFICIENCY (MI/KWH)'),
          const SizedBox(height: 8),
          _NumberInputField(
            controller: TextEditingController(
              text: _efficiency.toStringAsFixed(1),
            ),
            onChanged: (v) =>
                setState(() => _efficiency = double.tryParse(v) ?? 4.0),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const Text(
                  'ESTIMATED RANGE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_range.toStringAsFixed(0)} mi',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                    letterSpacing: -2,
                  ),
                ),
                Text(
                  '${(_range * 1.60934).toStringAsFixed(0)} km',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cost Calculator Sheet
// ---------------------------------------------------------------------------

class _CostCalculatorSheet extends StatefulWidget {
  const _CostCalculatorSheet();

  @override
  State<_CostCalculatorSheet> createState() => _CostCalculatorSheetState();
}

class _CostCalculatorSheetState extends State<_CostCalculatorSheet> {
  final _capacityCtrl = TextEditingController(text: '75');
  final _rateCtrl = TextEditingController(text: '0.13');
  double _fromCharge = 0.20;
  double _toCharge = 0.90;

  double get _kwhNeeded =>
      (double.tryParse(_capacityCtrl.text) ?? 75) *
      (_toCharge - _fromCharge).clamp(0, 1);

  double get _cost => _kwhNeeded * (double.tryParse(_rateCtrl.text) ?? 0.13);

  @override
  void dispose() {
    _capacityCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Cost Calculator',
      icon: Icons.attach_money,
      iconColor: const Color(0xFFF59E0B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('BATTERY CAPACITY (KWH)'),
          const SizedBox(height: 8),
          _NumberInputField(
            controller: _capacityCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          _FieldLabel('ELECTRICITY RATE (\$/KWH)'),
          const SizedBox(height: 8),
          _NumberInputField(
            controller: _rateCtrl,
            onChanged: (_) => setState(() {}),
            prefix: '\$',
          ),
          const SizedBox(height: 20),
          _FieldLabel('CHARGE FROM'),
          const SizedBox(height: 4),
          _SliderRow(
            value: _fromCharge,
            min: 0,
            max: 1,
            leftLabel: '0%',
            rightLabel: '${(_fromCharge * 100).round()}%',
            activeColor: const Color(0xFFF59E0B),
            onChanged: (v) {
              setState(() {
                _fromCharge = v;
                if (_toCharge <= _fromCharge) {
                  _toCharge = (_fromCharge + 0.05).clamp(0, 1);
                }
              });
            },
          ),
          const SizedBox(height: 20),
          _FieldLabel('CHARGE TO'),
          const SizedBox(height: 4),
          _SliderRow(
            value: _toCharge,
            min: 0,
            max: 1,
            leftLabel: '${(_fromCharge * 100).round()}%',
            rightLabel: '${(_toCharge * 100).round()}%',
            activeColor: const Color(0xFF22C55E),
            onChanged: (v) {
              setState(() {
                _toCharge = v;
                if (_toCharge <= _fromCharge) {
                  _fromCharge = (_toCharge - 0.05).clamp(0, 1);
                }
              });
            },
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ResultTile(
                  label: 'Energy Needed',
                  value: '${_kwhNeeded.toStringAsFixed(1)} kWh',
                  icon: Icons.bolt,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultTile(
                  label: 'Total Cost',
                  value: '\$${_cost.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable Bottom Sheet Wrapper
// ---------------------------------------------------------------------------

class _BottomSheetWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _BottomSheetWrapper({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sheet header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
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
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
