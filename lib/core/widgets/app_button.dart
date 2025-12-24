import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';

enum AppButtonStyle { primary, secondary, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonStyle style;
  final double? width;
  final IconData? icon; // Added icon support for a professional touch

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.style = AppButtonStyle.primary,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading || onPressed == null;

    return Container(
      width: width ?? double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: _getGradient(effectiveDisabled),
        color: _getBackgroundColor(effectiveDisabled),
        borderRadius: BorderRadius.circular(30), // Pill/Rounded style
        border: _getBorder(effectiveDisabled),
        boxShadow: _getShadow(effectiveDisabled),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Center(child: isLoading ? _buildLoader() : _buildContent()),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: _getTextColor()),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: _getTextColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoader() {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
      ),
    );
  }

  Gradient? _getGradient(bool disabled) {
    if (disabled) return null;
    if (style == AppButtonStyle.primary) {
      return AppColors.primaryGradient;
    }
    return null;
  }

  Color? _getBackgroundColor(bool disabled) {
    if (disabled) {
      return AppColors.textMuted.withValues(alpha: 0.2); // Disabled state
    }
    if (style == AppButtonStyle.primary) {
      return null; // Handled by gradient
    }
    if (style == AppButtonStyle.secondary) {
      return AppColors.skyBlue.withValues(alpha: 0.3); // Light background
    }
    return Colors.transparent; // Outline
  }

  BoxBorder? _getBorder(bool disabled) {
    if (style == AppButtonStyle.primary) return null;

    // Outline or Secondary
    final borderColor = disabled ? AppColors.textMuted : AppColors.primary;

    return Border.all(color: borderColor, width: 1.5);
  }

  List<BoxShadow>? _getShadow(bool disabled) {
    if (disabled || style == AppButtonStyle.outline) return null;

    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.3),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  Color _getTextColor() {
    if (isDisabled || onPressed == null) {
      return AppColors.textMuted;
    }
    if (style == AppButtonStyle.primary) {
      return Colors.white;
    }
    return AppColors.primary;
  }
}
