import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SettingsButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: AppTheme.glassBorder,
          width: 1,
        ),
        boxShadow: AppTheme.buttonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () {},
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.settings,
              color: AppTheme.textPrimary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

