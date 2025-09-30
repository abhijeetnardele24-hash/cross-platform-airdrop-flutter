# Animations & UI Effects Guide

## Overview
Comprehensive animation system with glass morphism effects, smooth page transitions, staggered list animations, and micro-interactions for buttons. All animations are optimized for both light and dark themes.

## Components Created

### 1. Enhanced Glass Morphism (`lib/widgets/enhanced_glass_card.dart`)

#### EnhancedGlassCard
Beautiful frosted glass effect with backdrop blur and interactive animations.

**Features:**
- Customizable blur intensity
- Adjustable opacity
- Border and shadow customization
- Tap animations (scale + opacity)
- Haptic feedback support
- Theme-aware styling

**Usage:**
```dart
EnhancedGlassCard(
  blur: 15.0,
  opacity: 0.2,
  onTap: () => print('Tapped!'),
  child: Text('Glass Morphism'),
)
```

**Parameters:**
- `blur`: Blur intensity (default: 10.0)
- `opacity`: Background opacity (default: 0.2)
- `padding`: Internal padding
- `margin`: External margin
- `borderRadius`: Corner radius
- `enableHoverEffect`: Enable hover animations
- `onTap`: Tap callback with animation

#### AnimatedGlassContainer
Glass card with continuous shimmer animation.

**Features:**
- Automatic shimmer effect
- Customizable animation duration
- Gradient-based shimmer
- Theme-adaptive colors

**Usage:**
```dart
AnimatedGlassContainer(
  blur: 12.0,
  opacity: 0.25,
  duration: Duration(milliseconds: 800),
  child: YourWidget(),
)
```

#### FrostedGlassAppBar
App bar with frosted glass effect.

**Features:**
- Backdrop blur effect
- Transparent background
- Theme-aware styling
- Standard AppBar API

**Usage:**
```dart
FrostedGlassAppBar(
  title: Text('Title'),
  actions: [IconButton(...)],
  blur: 10.0,
  opacity: 0.8,
)
```

### 2. Page Transitions (`lib/utils/page_transitions.dart`)

#### Available Transitions

**1. Cupertino Route (iOS-style)**
```dart
Navigator.push(
  context,
  PageTransitions.cupertinoRoute(DestinationScreen()),
);
```
- Native iOS slide animation
- Right-to-left transition
- Smooth and familiar

**2. Fade Transition**
```dart
Navigator.push(
  context,
  PageTransitions.fadeRoute(
    DestinationScreen(),
    duration: Duration(milliseconds: 300),
  ),
);
```
- Simple fade in/out
- Elegant and subtle
- Customizable duration

**3. Scale Transition**
```dart
Navigator.push(
  context,
  PageTransitions.scaleRoute(DestinationScreen()),
);
```
- Scale from 0.8 to 1.0
- Combined with fade
- Material Design inspired

**4. Slide from Bottom**
```dart
Navigator.push(
  context,
  PageTransitions.slideFromBottomRoute(DestinationScreen()),
);
```
- Bottom-to-top slide
- Perfect for modals
- Smooth easing curve

**5. Slide from Right**
```dart
Navigator.push(
  context,
  PageTransitions.slideFromRightRoute(DestinationScreen()),
);
```
- Right-to-left slide
- iOS-like behavior
- Customizable duration

**6. Shared Axis Transition**
```dart
Navigator.push(
  context,
  PageTransitions.sharedAxisRoute(
    DestinationScreen(),
    type: SharedAxisTransitionType.horizontal,
  ),
);
```
- Material Design 3 style
- Three types: horizontal, vertical, scaled
- Coordinated enter/exit animations

### 3. Staggered List Animations (`lib/widgets/staggered_list.dart`)

#### StaggeredListView
List with staggered entrance animations.

**Features:**
- Sequential item animations
- Customizable delay between items
- Fade + slide + scale effects
- Smooth easing curves

**Usage:**
```dart
StaggeredListView(
  itemCount: 20,
  delay: Duration(milliseconds: 50),
  itemDuration: Duration(milliseconds: 400),
  itemBuilder: (context, index) {
    return ListTile(title: Text('Item $index'));
  },
)
```

**Parameters:**
- `delay`: Delay between each item (default: 50ms)
- `itemDuration`: Animation duration per item (default: 400ms)
- `curve`: Animation curve (default: Curves.easeOutCubic)

#### StaggeredGridView
Grid with staggered animations.

**Usage:**
```dart
StaggeredGridView(
  itemCount: 12,
  crossAxisCount: 2,
  delay: Duration(milliseconds: 50),
  itemBuilder: (context, index) {
    return Card(child: Text('Item $index'));
  },
)
```

#### WaveAnimatedList
List with wave-like entrance animations.

**Features:**
- Elastic bounce effect
- Wave propagation
- Eye-catching entrance

**Usage:**
```dart
WaveAnimatedList(
  itemCount: 15,
  waveDelay: Duration(milliseconds: 100),
  itemBuilder: (context, index) {
    return YourWidget();
  },
)
```

#### CustomAnimatedList
List with custom animation types.

**Animation Types:**
- `slideAndFade`: Slide from right with fade
- `scaleAndFade`: Scale up with fade
- `rotateAndFade`: Rotate with fade
- `bounce`: Bounce from top

**Usage:**
```dart
CustomAnimatedList(
  itemCount: 10,
  animationType: AnimationType.bounce,
  itemBuilder: (context, index) {
    return YourWidget();
  },
)
```

### 4. Animated Buttons (`lib/widgets/animated_buttons.dart`)

#### AnimatedButton
Button with scale and elevation animations.

**Features:**
- Press animation (scale down)
- Elevation change
- Haptic feedback
- Customizable colors

**Usage:**
```dart
AnimatedButton(
  onPressed: () => print('Pressed!'),
  color: Colors.blue,
  enableHapticFeedback: true,
  child: Text('Press Me'),
)
```

#### BouncyButton
Button with spring bounce animation.

**Features:**
- Three-stage bounce (compress → expand → settle)
- Haptic feedback
- Shadow effects
- Satisfying interaction

**Usage:**
```dart
BouncyButton(
  onPressed: () => print('Bounced!'),
  color: Colors.green,
  child: Text('Bounce!'),
)
```

#### PulseButton
Button with continuous pulse animation.

**Features:**
- Continuous scale animation
- Attention-grabbing
- Can be disabled
- Smooth easing

**Usage:**
```dart
PulseButton(
  onPressed: () => print('Pulsed!'),
  color: Colors.purple,
  enablePulse: true,
  child: Text('Pulsing'),
)
```

#### RotatingIconButton
Icon button with rotation animation on tap.

**Features:**
- 360° rotation
- Smooth animation
- Haptic feedback
- Customizable duration

**Usage:**
```dart
RotatingIconButton(
  icon: Icons.refresh,
  onPressed: () => print('Rotated!'),
  color: Colors.blue,
  size: 32.0,
)
```

#### ShimmerButton
Button with animated gradient shimmer.

**Features:**
- Continuous gradient animation
- Customizable colors
- Eye-catching effect
- Haptic feedback

**Usage:**
```dart
ShimmerButton(
  onPressed: () => print('Shimmered!'),
  baseColor: Colors.orange,
  highlightColor: Colors.amber,
  child: Text('Shimmer'),
)
```

## Animation Testing Screen

Access via: **Settings → Developer Tools → Animation Showcase**

### Features:
1. **Glass Tab**: Test all glass morphism effects
2. **Buttons Tab**: Test all button micro-interactions
3. **Lists Tab**: See staggered list animations in action
4. **Transitions Tab**: Try all page transition types

### Testing Both Themes:
The animation test screen automatically adapts to light/dark theme. Toggle theme in Settings to test both.

## Performance Considerations

### Optimizations Applied:

1. **SingleTickerProviderStateMixin**
   - Efficient animation controllers
   - Automatic disposal
   - Minimal overhead

2. **AnimatedBuilder**
   - Rebuilds only animated widgets
   - Prevents unnecessary rebuilds
   - Optimal performance

3. **Backdrop Blur**
   - Hardware-accelerated
   - Efficient rendering
   - Platform-optimized

4. **Staggered Delays**
   - Prevents simultaneous animations
   - Smooth visual flow
   - No jank

### Performance Tips:

✅ **Do:**
- Use `const` constructors where possible
- Limit blur intensity (10-15 is optimal)
- Keep animation durations reasonable (200-400ms)
- Use `RepaintBoundary` for complex widgets

❌ **Don't:**
- Nest multiple blur effects
- Animate too many items simultaneously
- Use very long animation durations
- Forget to dispose controllers

## Theme Compatibility

### Light Theme
- Higher opacity for glass effects
- Darker shadows
- Brighter highlight colors
- Black/gray text

### Dark Theme
- Lower opacity for glass effects
- Lighter shadows
- Subtle highlight colors
- White/light gray text

### Auto-Adaptation
All widgets automatically adapt to theme changes:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

## Best Practices

### 1. Glass Morphism
```dart
// Good: Subtle and elegant
EnhancedGlassCard(
  blur: 10.0,
  opacity: 0.15,
  child: Content(),
)

// Avoid: Too intense
EnhancedGlassCard(
  blur: 50.0,  // Too blurry
  opacity: 0.8, // Too opaque
  child: Content(),
)
```

### 2. Page Transitions
```dart
// Good: Consistent with platform
if (Platform.isIOS) {
  PageTransitions.cupertinoRoute(screen);
} else {
  PageTransitions.sharedAxisRoute(screen);
}

// Good: Context-appropriate
// Modal-like screens
PageTransitions.slideFromBottomRoute(screen);

// Detail screens
PageTransitions.fadeRoute(screen);
```

### 3. List Animations
```dart
// Good: Subtle delay
StaggeredListView(
  delay: Duration(milliseconds: 50),
  itemDuration: Duration(milliseconds: 400),
  // ...
)

// Avoid: Too slow
StaggeredListView(
  delay: Duration(milliseconds: 200), // Too long
  // ...
)
```

### 4. Button Animations
```dart
// Good: Quick and responsive
AnimatedButton(
  animationDuration: Duration(milliseconds: 150),
  enableHapticFeedback: true,
  // ...
)

// Avoid: Too slow
AnimatedButton(
  animationDuration: Duration(milliseconds: 1000), // Too long
  // ...
)
```

## Integration Examples

### Example 1: Glass Card List
```dart
StaggeredListView(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return EnhancedGlassCard(
      blur: 10.0,
      opacity: 0.15,
      onTap: () => navigateToDetail(items[index]),
      child: ListTile(
        title: Text(items[index].name),
        subtitle: Text(items[index].description),
      ),
    );
  },
)
```

### Example 2: Animated Navigation
```dart
AnimatedButton(
  onPressed: () {
    Navigator.push(
      context,
      PageTransitions.scaleRoute(DetailScreen()),
    );
  },
  child: Text('View Details'),
)
```

### Example 3: Interactive Dashboard
```dart
StaggeredGridView(
  itemCount: dashboardItems.length,
  crossAxisCount: 2,
  itemBuilder: (context, index) {
    return AnimatedGlassContainer(
      blur: 12.0,
      child: DashboardCard(item: dashboardItems[index]),
    );
  },
)
```

## Accessibility

### Haptic Feedback
All interactive animations include optional haptic feedback:
```dart
AnimatedButton(
  enableHapticFeedback: true, // Default
  // ...
)
```

### Reduced Motion
Respect system accessibility settings:
```dart
final reducedMotion = MediaQuery.of(context).disableAnimations;

StaggeredListView(
  delay: reducedMotion 
    ? Duration.zero 
    : Duration(milliseconds: 50),
  // ...
)
```

### Screen Readers
All interactive elements are screen reader compatible with proper semantics.

## Troubleshooting

### Issue: Animations are janky
**Solutions:**
- Reduce blur intensity
- Decrease number of simultaneous animations
- Use `RepaintBoundary`
- Check for unnecessary rebuilds

### Issue: Glass effect not visible
**Solutions:**
- Increase opacity
- Check background contrast
- Ensure backdrop filter is supported
- Test on physical device

### Issue: Transitions feel slow
**Solutions:**
- Reduce transition duration
- Use faster curves (e.g., `Curves.easeOut`)
- Remove unnecessary animations

### Issue: Buttons not responding
**Solutions:**
- Check `onPressed` is not null
- Verify gesture detector hierarchy
- Test haptic feedback permissions

## Future Enhancements

### Planned Features:
1. **Hero Animations**: Shared element transitions
2. **Particle Effects**: Confetti, sparkles
3. **Lottie Integration**: Complex animations
4. **3D Transforms**: Perspective effects
5. **Physics-based Animations**: Spring, gravity
6. **Gesture Animations**: Swipe, pinch, rotate

---

**Status**: ✅ Fully Implemented and Tested
**Version**: 1.0.0
**Last Updated**: 2025-10-01
**Team**: Team Narcos

## Quick Reference

| Component | File | Use Case |
|-----------|------|----------|
| EnhancedGlassCard | enhanced_glass_card.dart | Cards, containers |
| AnimatedGlassContainer | enhanced_glass_card.dart | Shimmer effects |
| FrostedGlassAppBar | enhanced_glass_card.dart | App bars |
| CupertinoRoute | page_transitions.dart | iOS navigation |
| FadeRoute | page_transitions.dart | Subtle transitions |
| ScaleRoute | page_transitions.dart | Modal-like screens |
| StaggeredListView | staggered_list.dart | List animations |
| WaveAnimatedList | staggered_list.dart | Playful lists |
| AnimatedButton | animated_buttons.dart | Primary actions |
| BouncyButton | animated_buttons.dart | Fun interactions |
| PulseButton | animated_buttons.dart | Attention-grabbing |
| ShimmerButton | animated_buttons.dart | Premium feel |
