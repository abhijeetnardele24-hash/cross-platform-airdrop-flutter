import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Staggered animation for list items
class StaggeredListView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration delay;
  final Duration itemDuration;
  final Curve curve;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

  const StaggeredListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.delay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      physics: physics,
      padding: padding,
      shrinkWrap: shrinkWrap,
      itemBuilder: (context, index) {
        return StaggeredListItem(
          index: index,
          delay: delay,
          duration: itemDuration,
          curve: curve,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// Individual staggered list item with animation
class StaggeredListItem extends StatefulWidget {
  final int index;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Widget child;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.delay,
    required this.duration,
    required this.curve,
    required this.child,
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Stagger the animation based on index
    final delayMillis = widget.index * widget.delay.inMilliseconds;
    Future.delayed(Duration(milliseconds: delayMillis), () {
      if (mounted) {
        _controller.forward();
      }
    });

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Grid view with staggered animations
class StaggeredGridView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int crossAxisCount;
  final double childAspectRatio;
  final Duration delay;
  final Duration itemDuration;
  final Curve curve;
  final EdgeInsetsGeometry? padding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const StaggeredGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.delay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.padding,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemBuilder: (context, index) {
        return StaggeredListItem(
          index: index,
          delay: delay,
          duration: itemDuration,
          curve: curve,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// Wave animation for list items
class WaveAnimatedList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration waveDelay;
  final Duration itemDuration;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const WaveAnimatedList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.waveDelay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 600),
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      physics: physics,
      padding: padding,
      itemBuilder: (context, index) {
        return WaveAnimatedItem(
          index: index,
          delay: waveDelay,
          duration: itemDuration,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// Individual wave animated item
class WaveAnimatedItem extends StatefulWidget {
  final int index;
  final Duration delay;
  final Duration duration;
  final Widget child;

  const WaveAnimatedItem({
    super.key,
    required this.index,
    required this.delay,
    required this.duration,
    required this.child,
  });

  @override
  State<WaveAnimatedItem> createState() => _WaveAnimatedItemState();
}

class _WaveAnimatedItemState extends State<WaveAnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final delayMillis = widget.index * widget.delay.inMilliseconds;
    Future.delayed(Duration(milliseconds: delayMillis), () {
      if (mounted) {
        _controller.forward();
      }
    });

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final translateY = (1 - value) * 50;
        final scale = 0.8 + (value * 0.2);

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Animated list with custom entrance animations
class CustomAnimatedList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final AnimationType animationType;
  final Duration delay;
  final Duration duration;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const CustomAnimatedList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.animationType = AnimationType.slideAndFade,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 400),
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      physics: physics,
      padding: padding,
      itemBuilder: (context, index) {
        return _AnimatedListItem(
          index: index,
          delay: delay,
          duration: duration,
          animationType: animationType,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

enum AnimationType {
  slideAndFade,
  scaleAndFade,
  rotateAndFade,
  bounce,
}

class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Duration delay;
  final Duration duration;
  final AnimationType animationType;
  final Widget child;

  const _AnimatedListItem({
    required this.index,
    required this.delay,
    required this.duration,
    required this.animationType,
    required this.child,
  });

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final delayMillis = widget.index * widget.delay.inMilliseconds;
    Future.delayed(Duration(milliseconds: delayMillis), () {
      if (mounted) {
        _controller.forward();
      }
    });

    _animation = CurvedAnimation(
      parent: _controller,
      curve: _getCurve(),
    );
  }

  Curve _getCurve() {
    switch (widget.animationType) {
      case AnimationType.bounce:
        return Curves.bounceOut;
      case AnimationType.rotateAndFade:
        return Curves.easeInOutBack;
      default:
        return Curves.easeOutCubic;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return _buildAnimation(child!);
      },
      child: widget.child,
    );
  }

  Widget _buildAnimation(Widget child) {
    final value = _animation.value;

    switch (widget.animationType) {
      case AnimationType.slideAndFade:
        return Transform.translate(
          offset: Offset((1 - value) * 50, 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );

      case AnimationType.scaleAndFade:
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );

      case AnimationType.rotateAndFade:
        return Transform.rotate(
          angle: (1 - value) * math.pi / 4,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );

      case AnimationType.bounce:
        return Transform.translate(
          offset: Offset(0, (1 - value) * 100),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
    }
  }
}
