import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/ios_theme.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool enableHaptic;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.margin,
    this.padding,
    this.borderRadius,
    this.blur = 20.0,
    this.opacity = 0.15,
    this.color,
    this.border,
    this.boxShadow,
    this.onTap,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = color ?? (isDark ? Colors.white : Colors.white);
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: defaultColor.withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: border ?? Border.all(
                color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap != null ? () {
                  if (enableHaptic) HapticFeedback.lightImpact();
                  onTap!();
                } : null,
                borderRadius: borderRadius ?? BorderRadius.circular(16),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final bool enableHover;

  const AnimatedGlassCard({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.margin,
    this.padding,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableHover = true,
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.15,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _blurAnimation = Tween<double>(
      begin: 20.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    if (!widget.enableHover) return;
    setState(() => _isHovered = true);
    if (!_isPressed) _controller.forward();
  }

  void _handleHoverExit(PointerExitEvent event) {
    if (!widget.enableHover) return;
    setState(() => _isHovered = false);
    if (!_isPressed) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: _handleHoverEnter,
            onExit: _handleHoverExit,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: GlassmorphicContainer(
                width: widget.width,
                height: widget.height,
                margin: widget.margin,
                padding: widget.padding,
                blur: _blurAnimation.value,
                opacity: _opacityAnimation.value,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class GlassmorphicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final double elevation;

  const GlassmorphicAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.blur = 20.0,
    this.opacity = 0.8,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = backgroundColor ?? (isDark ? Colors.black : Colors.white);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: defaultColor.withOpacity(opacity),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: AppBar(
            leading: leading,
            title: title,
            actions: actions,
            backgroundColor: Colors.transparent,
            elevation: elevation,
            systemOverlayStyle: isDark 
              ? SystemUiOverlayStyle.light 
              : SystemUiOverlayStyle.dark,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class GlassmorphicBottomSheet extends StatelessWidget {
  final Widget child;
  final double? height;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const GlassmorphicBottomSheet({
    super.key,
    required this.child,
    this.height,
    this.blur = 20.0,
    this.opacity = 0.9,
    this.backgroundColor,
    this.borderRadius,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? height,
    double blur = 20.0,
    double opacity = 0.9,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      builder: (context) => GlassmorphicBottomSheet(
        height: height,
        blur: blur,
        opacity: opacity,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = backgroundColor ?? (isDark ? Colors.black : Colors.white);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: height ?? screenHeight * 0.6,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: defaultColor.withOpacity(opacity),
              borderRadius: borderRadius ?? const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassmorphicDialog extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const GlassmorphicDialog({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.blur = 20.0,
    this.opacity = 0.9,
    this.backgroundColor,
    this.borderRadius,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? width,
    double? height,
    double blur = 20.0,
    double opacity = 0.9,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => GlassmorphicDialog(
        width: width,
        height: height,
        blur: blur,
        opacity: opacity,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = backgroundColor ?? (isDark ? Colors.black : Colors.white);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              decoration: BoxDecoration(
                color: defaultColor.withOpacity(opacity),
                borderRadius: borderRadius ?? BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassmorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool enableHaptic;

  const GlassmorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.blur = 15.0,
    this.opacity = 0.2,
    this.backgroundColor,
    this.borderRadius,
    this.enableHaptic = true,
  });

  @override
  State<GlassmorphicButton> createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<GlassmorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.opacity,
      end: widget.opacity * 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.enableHaptic) HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = widget.backgroundColor ?? (isDark ? Colors.white : Colors.white);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: widget.width,
              height: widget.height ?? 50,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.blur,
                    sigmaY: widget.blur,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: defaultColor.withOpacity(_opacityAnimation.value),
                      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(isDark ? 0.2 : 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: widget.padding ?? const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
