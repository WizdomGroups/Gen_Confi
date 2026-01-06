import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';

enum AppButtonStyle { primary, secondary, outline, ghost }

enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonStyle style;
  final AppButtonSize size;
  final double? width;
  final IconData? icon;
  final IconData? suffixIcon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.style = AppButtonStyle.primary,
    this.size = AppButtonSize.medium,
    this.width,
    this.icon,
    this.suffixIcon,
    this.fullWidth = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isEffectiveDisabled) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isEffectiveDisabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!_isEffectiveDisabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  bool get _isEffectiveDisabled =>
      widget.isDisabled || widget.isLoading || widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.fullWidth
            ? (widget.width ?? double.infinity)
            : widget.width,
        height: dimensions.height,
        decoration: BoxDecoration(
          gradient: _getGradient(),
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
          border: _getBorder(),
          boxShadow: _getShadow(),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isEffectiveDisabled ? null : widget.onPressed,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            borderRadius: BorderRadius.circular(dimensions.borderRadius),
            splashColor: _getSplashColor(),
            highlightColor: _getHighlightColor(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: dimensions.horizontalPadding,
              ),
              child: Center(
                child: widget.isLoading ? _buildLoader() : _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final dimensions = _getDimensions();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: dimensions.iconSize, color: _getTextColor()),
          SizedBox(width: dimensions.iconSpacing),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: dimensions.fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: _getTextColor(),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (widget.suffixIcon != null) ...[
          SizedBox(width: dimensions.iconSpacing),
          Icon(
            widget.suffixIcon,
            size: dimensions.iconSize,
            color: _getTextColor(),
          ),
        ],
      ],
    );
  }

  Widget _buildLoader() {
    final dimensions = _getDimensions();
    return SizedBox(
      height: dimensions.loaderSize,
      width: dimensions.loaderSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
      ),
    );
  }

  _ButtonDimensions _getDimensions() {
    switch (widget.size) {
      case AppButtonSize.small:
        return _ButtonDimensions(
          height: 40,
          fontSize: 13,
          iconSize: 16,
          iconSpacing: 6,
          horizontalPadding: 16,
          borderRadius: 12,
          loaderSize: 16,
        );
      case AppButtonSize.medium:
        return _ButtonDimensions(
          height: 52,
          fontSize: 15,
          iconSize: 20,
          iconSpacing: 8,
          horizontalPadding: 20,
          borderRadius: 16,
          loaderSize: 20,
        );
      case AppButtonSize.large:
        return _ButtonDimensions(
          height: 60,
          fontSize: 17,
          iconSize: 24,
          iconSpacing: 10,
          horizontalPadding: 24,
          borderRadius: 18,
          loaderSize: 24,
        );
    }
  }

  Gradient? _getGradient() {
    if (_isEffectiveDisabled) return null;
    if (widget.style == AppButtonStyle.primary) {
      return AppColors.primaryGradient;
    }
    return null;
  }

  Color? _getBackgroundColor() {
    if (_isEffectiveDisabled) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return isDark ? AppColors.surfaceElevatedDark : const Color(0xFFE2E8F0);
    }

    switch (widget.style) {
      case AppButtonStyle.primary:
        return null; // Gradient handles this.
      case AppButtonStyle.secondary:
        return _isPressed
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.primary.withOpacity(0.08);
      case AppButtonStyle.outline:
      case AppButtonStyle.ghost:
        return _isPressed
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent;
    }
  }

  BoxBorder? _getBorder() {
    if (widget.style == AppButtonStyle.primary ||
        widget.style == AppButtonStyle.ghost) {
      return null;
    }

    final borderColor = _isEffectiveDisabled
        ? const Color(0xFFCBD5E1)
        : AppColors.primary;

    return Border.all(
      color: borderColor,
      width: widget.style == AppButtonStyle.outline ? 2.0 : 1.5,
    );
  }

  List<BoxShadow>? _getShadow() {
    if (_isEffectiveDisabled ||
        widget.style == AppButtonStyle.outline ||
        widget.style == AppButtonStyle.ghost) {
      return null;
    }

    if (widget.style == AppButtonStyle.primary) {
      return [
        BoxShadow(
          color: AppColors.gradientStart.withOpacity(_isPressed ? 0.2 : 0.3),
          blurRadius: _isPressed ? 12 : 16,
          offset: Offset(0, _isPressed ? 4 : 8),
        ),
      ];
    }

    // Secondary style shadow
    return [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  Color _getSplashColor() {
    if (widget.style == AppButtonStyle.primary) {
      return Colors.white.withOpacity(0.2);
    }
    return AppColors.primary.withOpacity(0.1);
  }

  Color _getHighlightColor() {
    if (widget.style == AppButtonStyle.primary) {
      return Colors.white.withOpacity(0.1);
    }
    return AppColors.primary.withOpacity(0.05);
  }

  Color _getTextColor() {
    if (_isEffectiveDisabled) {
      return const Color(0xFF94A3B8);
    }

    switch (widget.style) {
      case AppButtonStyle.primary:
        return Colors.white;
      case AppButtonStyle.secondary:
      case AppButtonStyle.outline:
      case AppButtonStyle.ghost:
        return AppColors.primary;
    }
  }
}

class _ButtonDimensions {
  final double height;
  final double fontSize;
  final double iconSize;
  final double iconSpacing;
  final double horizontalPadding;
  final double borderRadius;
  final double loaderSize;

  _ButtonDimensions({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.iconSpacing,
    required this.horizontalPadding,
    required this.borderRadius,
    required this.loaderSize,
  });
}
