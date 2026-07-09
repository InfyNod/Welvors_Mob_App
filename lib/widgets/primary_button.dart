import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;   // null → disabled
  final bool isLoading;
  const PrimaryButton(this.label, {this.onTap, this.isLoading = false, super.key});

  @override
  Widget build(BuildContext context) {
    final on = onTap != null && !isLoading;
    return GestureDetector(
      onTap: on ? onTap : null,
      child: Container(
        height: AppDimens.btnH,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? AppColors.pinkDeep : const Color(0xFFEFECE8), 
          borderRadius: BorderRadius.circular(AppDimens.rInput),
          border: on ? null : Border.all(color: AppColors.line, width: 1.5),
          boxShadow: on ? [BoxShadow(
            color: AppColors.pinkDeep.withOpacity(0.3),
            blurRadius: 20, offset: const Offset(0, 8))] : null,
        ),
        child: isLoading 
          ? const SizedBox(
              height: 20, 
              width: 20, 
              child: CircularProgressIndicator(
                strokeWidth: 2, 
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink60),
              )
            )
          : Text(label, style: AppText.button.copyWith(
              color: on ? AppColors.line : AppColors.ink60,
            )),
      ),
    );
  }
}