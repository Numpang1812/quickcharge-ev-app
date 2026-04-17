import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/operator_chip.dart';
import '../widgets/plug_card.dart';
import '../widgets/speed_chip.dart';

class FilterStationsScreen extends StatefulWidget {
  const FilterStationsScreen({super.key});

  @override
  State<FilterStationsScreen> createState() => _FilterStationsScreenState();
}

class _FilterStationsScreenState extends State<FilterStationsScreen> {
  String selectedOperator = 'EcoCharge';
  String selectedPlug = 'CCS';
  String selectedSpeed = 'Fast';
  RangeValues selectedPrice = const RangeValues(0.10, 0.45);

  final List<String> operators = ['EcoCharge', 'SmartCharge', 'FastVolt'];
  final List<String> plugs = ['CCS', 'Type 2', 'CHAdeMO', 'Tesla'];
  final List<String> speeds = ['Normal', 'Fast', 'Ultra Fast'];

  void resetFilters() {
    setState(() {
      selectedOperator = 'EcoCharge';
      selectedPlug = 'CCS';
      selectedSpeed = 'Fast';
      selectedPrice = const RangeValues(0.10, 0.45);
    });
  }

  void applyFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Applied: $selectedOperator, $selectedPlug, $selectedSpeed, '
          '\$${selectedPrice.start.toStringAsFixed(2)} - \$${selectedPrice.end.toStringAsFixed(2)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('OPERATORS'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: operators.map((item) {
                        return OperatorChip(
                          label: item,
                          isSelected: selectedOperator == item,
                          onTap: () {
                            setState(() {
                              selectedOperator = item;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle('PLUG TYPES'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: plugs.map((item) {
                        return PlugCard(
                          label: item,
                          isSelected: selectedPlug == item,
                          onTap: () {
                            setState(() {
                              selectedPlug = item;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('PRICE RANGE'),
                        Text(
                          '\$${selectedPrice.start.toStringAsFixed(2)} - \$${selectedPrice.end.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.sectionTitle,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryGreen,
                        inactiveTrackColor: const Color(0xFFE4E8F0),
                        thumbColor: AppColors.accentBlue,
                        overlayColor: AppColors.accentBlue.withOpacity(0.15),
                        trackHeight: 8,
                        rangeThumbShape: const RoundRangeSliderThumbShape(
                          enabledThumbRadius: 11,
                        ),
                        rangeTrackShape:
                            const RoundedRectRangeSliderTrackShape(),
                      ),
                      child: RangeSlider(
                        values: selectedPrice,
                        min: 0.10,
                        max: 0.45,
                        divisions: 35,
                        onChanged: (values) {
                          setState(() {
                            selectedPrice = values;
                          });
                        },
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$0.10',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$0.45',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    _buildSectionTitle('CHARGING SPEED'),
                    const SizedBox(height: 16),
                    Row(
                      children: speeds.map((item) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: item != speeds.last ? 12 : 0,
                            ),
                            child: SpeedChip(
                              label: item,
                              isSelected: selectedSpeed == item,
                              onTap: () {
                                setState(() {
                                  selectedSpeed = item;
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryGreen,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Filter Stations',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: resetFilters,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppColors.accentBlue,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.sectionTitle,
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.accentBlue],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBlue.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: const Text(
              'Apply Filters',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
