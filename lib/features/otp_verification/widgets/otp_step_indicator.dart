import 'package:flutter/material.dart';
import 'package:naqde_user/util/dimensions.dart';

/// Bilingual step progress indicator — mirrors the HTML's step-indicator.
/// Shows 4 steps: Register → Info → Verify → Done
class OtpStepIndicator extends StatelessWidget {
  /// 1-based index of the currently active step
  final int currentStep;
  final int totalSteps;

  const OtpStepIndicator({
    super.key,
    this.currentStep = 3,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final success = const Color(0xFF10B981);

    return Semantics(
      label: 'Step $currentStep of $totalSteps',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeOverLarge,
          vertical: Dimensions.paddingSizeLarge,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Connecting line
            Positioned(
              top: 14,
              left: 40,
              right: 40,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      success,
                      success,
                      primary.withValues(alpha: 0.3),
                      primary.withValues(alpha: 0.1),
                    ],
                    stops: [0, (currentStep - 1) / (totalSteps - 1), (currentStep - 1) / (totalSteps - 1), 1],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(totalSteps, (i) {
                final step = i + 1;
                final isCompleted = step < currentStep;
                final isActive = step == currentStep;

                return _StepBubble(
                  step: step,
                  isCompleted: isCompleted,
                  isActive: isActive,
                  primary: primary,
                  success: success,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBubble extends StatelessWidget {
  final int step;
  final bool isCompleted;
  final bool isActive;
  final Color primary;
  final Color success;

  const _StepBubble({
    required this.step,
    required this.isCompleted,
    required this.isActive,
    required this.primary,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    double scale = 1.0;

    if (isCompleted) {
      bg = success;
      fg = Colors.white;
    } else if (isActive) {
      bg = primary;
      fg = Colors.white;
      scale = 1.15;
    } else {
      bg = Colors.grey.shade300;
      fg = Colors.grey.shade500;
    }

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: isActive
              ? [BoxShadow(color: primary.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text(
                  '$step',
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
        ),
      ),
    );
  }
}
