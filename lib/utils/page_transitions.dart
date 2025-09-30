import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Custom page transitions for smooth navigation
class PageTransitions {
  /// iOS-style slide transition
  static Route<T> cupertinoRoute<T>(Widget page) {
    return CupertinoPageRoute<T>(
      builder: (context) => page,
    );
  }

  /// Fade transition
  static Route<T> fadeRoute<T>(Widget page, {Duration? duration}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Scale and fade transition
  static Route<T> scaleRoute<T>(Widget page, {Duration? duration}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.8;
        const end = 1.0;
        const curve = Curves.easeInOutCubic;

        var scaleTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Slide from bottom transition
  static Route<T> slideFromBottomRoute<T>(Widget page, {Duration? duration}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Slide from right transition (iOS-like)
  static Route<T> slideFromRightRoute<T>(Widget page, {Duration? duration}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Rotation and fade transition
  static Route<T> rotationRoute<T>(Widget page, {Duration? duration}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        var rotationTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return RotationTransition(
          turns: animation.drive(rotationTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Shared axis transition (Material Design)
  static Route<T> sharedAxisRoute<T>(
    Widget page, {
    Duration? duration,
    SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
          child: child,
        );
      },
    );
  }
}

/// Shared axis transition types
enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

/// Shared axis transition widget
class SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final SharedAxisTransitionType transitionType;
  final Widget child;

  const SharedAxisTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        return _buildHorizontalTransition();
      case SharedAxisTransitionType.vertical:
        return _buildVerticalTransition();
      case SharedAxisTransitionType.scaled:
        return _buildScaledTransition();
    }
  }

  Widget _buildHorizontalTransition() {
    final incomingTween = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeInOutCubic));

    final outgoingTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).chain(CurveTween(curve: Curves.easeInOutCubic));

    return SlideTransition(
      position: animation.drive(incomingTween),
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: secondaryAnimation.drive(outgoingTween),
          child: child,
        ),
      ),
    );
  }

  Widget _buildVerticalTransition() {
    final incomingTween = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeInOutCubic));

    final outgoingTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.3),
    ).chain(CurveTween(curve: Curves.easeInOutCubic));

    return SlideTransition(
      position: animation.drive(incomingTween),
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: secondaryAnimation.drive(outgoingTween),
          child: child,
        ),
      ),
    );
  }

  Widget _buildScaledTransition() {
    final incomingTween = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeInOutCubic));

    final outgoingTween = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).chain(CurveTween(curve: Curves.easeInOutCubic));

    return ScaleTransition(
      scale: animation.drive(incomingTween),
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: secondaryAnimation.drive(outgoingTween),
          child: child,
        ),
      ),
    );
  }
}

/// Hero-style page transition
class HeroDialogRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  HeroDialogRoute({required this.builder})
      : super(settings: const RouteSettings());

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  String? get barrierLabel => 'Dismiss';
}
