import 'package:flutter/material.dart';

/// Optimized list view builder with better performance
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  
  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.physics,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      physics: physics ?? const BouncingScrollPhysics(),
      padding: padding,
      // Performance optimizations
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      cacheExtent: 100,
    );
  }
}

/// Optimized grid view with better performance
class OptimizedGridView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  
  const OptimizedGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.crossAxisCount,
    this.childAspectRatio = 1.0,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
      ),
      padding: padding,
      // Performance optimizations
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      cacheExtent: 100,
    );
  }
}

/// RepaintBoundary wrapper for expensive widgets
class OptimizedRepaintBoundary extends StatelessWidget {
  final Widget child;
  
  const OptimizedRepaintBoundary({
    super.key,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: child);
  }
}
