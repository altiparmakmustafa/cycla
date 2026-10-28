import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CyclaLogo extends StatelessWidget {
  final double size;
  final double borderRadius;

  const CyclaLogo({
    super.key,
    this.size = 38,
    this.borderRadius = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.primary.withOpacityFactor(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacityFactor(0.22),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/cycla_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.surfaceElevated,
            alignment: Alignment.center,
            child: Icon(
              Icons.donut_large_rounded,
              color: AppColors.secondary,
              size: size * 0.58,
            ),
          ),
        ),
      ),
    );
  }
}

