import 'package:flutter/material.dart';
import 'app_colors.dart';

class OperatorChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const OperatorChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [
              AppColors.primaryGreen,
              AppColors.primaryGreenDark,
            ],
          )
              : null,
          color: isSelected ? null : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
