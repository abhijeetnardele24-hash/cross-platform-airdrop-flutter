# iOS Components Guide

## Overview
Complete iOS-style UI components using Cupertino widgets with integrated haptic feedback. All components follow Apple's Human Interface Guidelines for a native iOS experience.

## Components Library

### 1. Bottom Sheets & Modals (`lib/widgets/ios_components.dart`)

#### IOSBottomSheet
iOS-style bottom sheet with drag handle and blur effect.

**Features:**
- Drag handle for dismissal
- Customizable height
- Blur background
- Haptic feedback on show/dismiss
- Theme-aware styling

**Usage:**
```dart
IOSBottomSheet.show(
  context: context,
  child: YourContent(),
  height: 400,
  isDismissible: true,
  enableDrag: true,
);
```

**Parameters:**
- `child`: Widget to display in bottom sheet
- `height`: Sheet height (default: 60% of screen)
- `isDismissible`: Allow tap outside to dismiss
- `backgroundColor`: Custom background color
- `enableDrag`: Show drag handle

#### IOSBottomSheet.showActionSheet
Native iOS action sheet with multiple actions.

**Features:**
- Title and message support
- Multiple action buttons
- Cancel button
- Destructive action styling
- Haptic feedback for each action

**Usage:**
```dart
IOSBottomSheet.showActionSheet(
  context: context,
  title: 'Choose an action',
  message: 'Select one of the options below',
  actions: [
    IOSActionSheetAction(
      label: 'Share',
      onPressed: () => share(),
      isDefaultAction: true,
    ),
    IOSActionSheetAction(
      label: 'Delete',
      onPressed: () => delete(),
      isDestructiveAction: true,
    ),
  ],
  cancelAction: IOSActionSheetAction(
    label: 'Cancel',
    onPressed: () {},
  ),
);
```

#### IOSBottomSheet.showPickerSheet
Bottom sheet with picker and done button.

**Usage:**
```dart
IOSBottomSheet.showPickerSheet(
  context: context,
  title: 'Select Date',
  picker: CupertinoDatePicker(
    onDateTimeChanged: (DateTime date) {
      // Handle date change
    },
  ),
  onDone: () {
    // Handle done
  },
);
```

### 2. Alert Dialogs

#### IOSAlertDialog.show
Native iOS alert dialog.

**Usage:**
```dart
IOSAlertDialog.show(
  context: context,
  title: 'Alert',
  message: 'This is an important message',
  actions: [
    IOSAlertAction(
      label: 'Cancel',
      onPressed: () {},
    ),
    IOSAlertAction(
      label: 'OK',
      onPressed: () {},
      isDefaultAction: true,
    ),
  ],
);
```

#### IOSAlertDialog.showConfirmation
Confirmation dialog with yes/no options.

**Usage:**
```dart
final confirmed = await IOSAlertDialog.showConfirmation(
  context: context,
  title: 'Confirm Delete',
  message: 'Are you sure you want to delete this item?',
  confirmLabel: 'Delete',
  cancelLabel: 'Cancel',
  isDestructive: true,
);

if (confirmed) {
  // User confirmed
}
```

### 3. Switches & Toggles (`lib/widgets/ios_switches.dart`)

#### IOSSwitch
Native Cupertino switch with haptic feedback.

**Features:**
- Haptic feedback on toggle
- Custom active color
- Disabled state support
- Smooth animation

**Usage:**
```dart
IOSSwitch(
  value: isEnabled,
  onChanged: (value) => setState(() => isEnabled = value),
  activeColor: CupertinoColors.activeGreen,
)
```

#### IOSToggle
Switch with label and subtitle.

**Features:**
- Icon support
- Title and subtitle
- Tap anywhere to toggle
- Haptic feedback
- Theme-aware styling

**Usage:**
```dart
IOSToggle(
  label: 'Notifications',
  subtitle: 'Receive push notifications',
  value: notificationsEnabled,
  onChanged: (value) => setState(() => notificationsEnabled = value),
  icon: CupertinoIcons.bell_fill,
  activeColor: CupertinoColors.activeGreen,
)
```

#### IOSCheckbox
iOS-style checkbox (circular with checkmark).

**Usage:**
```dart
Row(
  children: [
    IOSCheckbox(
      value: isChecked,
      onChanged: (value) => setState(() => isChecked = value),
      activeColor: CupertinoColors.activeBlue,
    ),
    SizedBox(width: 12),
    Text('Accept terms'),
  ],
)
```

#### IOSRadio
iOS-style radio button.

**Usage:**
```dart
Column(
  children: [
    Row(
      children: [
        IOSRadio<String>(
          value: 'option1',
          groupValue: selectedOption,
          onChanged: (value) => setState(() => selectedOption = value),
        ),
        SizedBox(width: 12),
        Text('Option 1'),
      ],
    ),
    // More options...
  ],
)
```

#### IOSSlider
Cupertino slider with haptic feedback.

**Usage:**
```dart
IOSSlider(
  value: volume,
  onChanged: (value) => setState(() => volume = value),
  min: 0.0,
  max: 1.0,
  divisions: 10,
  activeColor: CupertinoColors.activeBlue,
)
```

#### IOSSegmentedButton
Segmented control with multiple options.

**Usage:**
```dart
IOSSegmentedButton<int>(
  value: selectedSegment,
  segments: [
    IOSSegment(value: 0, child: Text('List')),
    IOSSegment(value: 1, child: Text('Grid')),
    IOSSegment(value: 2, child: Text('Card')),
  ],
  onChanged: (value) => setState(() => selectedSegment = value),
)
```

#### IOSToggleButtons
Multiple toggle buttons (like formatting toolbar).

**Usage:**
```dart
IOSToggleButtons(
  isSelected: [isBold, isItalic, isUnderline],
  children: [
    Icon(CupertinoIcons.bold),
    Icon(CupertinoIcons.italic),
    Icon(CupertinoIcons.underline),
  ],
  onPressed: (index) {
    setState(() {
      if (index == 0) isBold = !isBold;
      if (index == 1) isItalic = !isItalic;
      if (index == 2) isUnderline = !isUnderline;
    });
  },
)
```

### 4. Context Menu

#### IOSContextMenu
Long-press context menu with actions.

**Features:**
- Long-press activation
- Multiple actions
- Icons support
- Destructive action styling
- Haptic feedback

**Usage:**
```dart
IOSContextMenu(
  actions: [
    IOSContextMenuAction(
      label: 'Copy',
      onPressed: () => copy(),
      icon: CupertinoIcons.doc_on_doc,
    ),
    IOSContextMenuAction(
      label: 'Share',
      onPressed: () => share(),
      icon: CupertinoIcons.share,
    ),
    IOSContextMenuAction(
      label: 'Delete',
      onPressed: () => delete(),
      icon: CupertinoIcons.delete,
      isDestructiveAction: true,
    ),
  ],
  child: YourWidget(),
)
```

### 5. Navigation & Loading

#### IOSNavigationBar
Cupertino navigation bar.

**Usage:**
```dart
CupertinoPageScaffold(
  navigationBar: IOSNavigationBar(
    middle: Text('Title'),
    leading: CupertinoButton(
      padding: EdgeInsets.zero,
      child: Icon(CupertinoIcons.back),
      onPressed: () => Navigator.pop(context),
    ),
    trailing: CupertinoButton(
      padding: EdgeInsets.zero,
      child: Icon(CupertinoIcons.add),
      onPressed: () => addItem(),
    ),
  ),
  child: YourContent(),
)
```

#### IOSLoadingIndicator
Native iOS activity indicator.

**Usage:**
```dart
IOSLoadingIndicator(
  radius: 15.0,
  color: CupertinoColors.activeBlue,
)
```

## Haptic Feedback Integration

All interactive components include haptic feedback using the `haptic_feedback` package.

### Haptic Types Used:

1. **Selection** - Light tap
   - Used for: Switches, toggles, buttons, segmented controls
   - Feel: Quick, light feedback

2. **Warning** - Medium impact
   - Used for: Alert dialogs, destructive actions
   - Feel: Noticeable, cautionary

3. **Success** - Success notification
   - Used for: Confirmations, completions
   - Feel: Positive, satisfying

### Manual Haptic Feedback:
```dart
import 'package:haptic_feedback/haptic_feedback.dart';

// Light selection
await Haptics.vibrate(HapticsType.selection);

// Medium impact
await Haptics.vibrate(HapticsType.medium);

// Heavy impact
await Haptics.vibrate(HapticsType.heavy);

// Warning
await Haptics.vibrate(HapticsType.warning);

// Success
await Haptics.vibrate(HapticsType.success);

// Error
await Haptics.vibrate(HapticsType.error);
```

## Testing Screen

Access via: **Settings → Developer Tools → iOS Components**

### Features:
- Test all switches and toggles
- Try checkboxes and radio buttons
- Experiment with sliders and segments
- Show bottom sheets and action sheets
- Test alert dialogs
- Try context menus
- View loading indicators

## Theme Compatibility

All components automatically adapt to light and dark themes using Cupertino's theme system.

### Light Theme Colors:
- Background: `CupertinoColors.systemBackground` (white)
- Text: `CupertinoColors.label` (black)
- Separator: `CupertinoColors.separator` (light gray)
- Active: `CupertinoColors.activeBlue`

### Dark Theme Colors:
- Background: `CupertinoColors.darkBackgroundGray`
- Text: `CupertinoColors.white`
- Separator: `CupertinoColors.separator` (dark gray)
- Active: `CupertinoColors.activeBlue`

### Accessing Theme:
```dart
final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

final backgroundColor = isDark
    ? CupertinoColors.darkBackgroundGray
    : CupertinoColors.white;
```

## Best Practices

### 1. Use Cupertino Scaffold
```dart
// Good: iOS-style scaffold
CupertinoPageScaffold(
  navigationBar: IOSNavigationBar(middle: Text('Title')),
  child: Content(),
)

// Avoid: Material scaffold on iOS
Scaffold(
  appBar: AppBar(title: Text('Title')),
  body: Content(),
)
```

### 2. Consistent Haptic Feedback
```dart
// Good: Haptic feedback on interaction
IOSSwitch(
  value: value,
  onChanged: (newValue) {
    // Haptic is automatic
    setState(() => value = newValue);
  },
)

// Avoid: No feedback
Switch(
  value: value,
  onChanged: (newValue) {
    // No haptic feedback
    setState(() => value = newValue);
  },
)
```

### 3. Use Action Sheets for Multiple Options
```dart
// Good: Action sheet for 3+ options
IOSBottomSheet.showActionSheet(
  context: context,
  actions: multipleActions,
);

// Avoid: Multiple dialogs
showDialog(...); // Don't chain dialogs
```

### 4. Destructive Actions
```dart
// Good: Mark destructive actions
IOSActionSheetAction(
  label: 'Delete',
  onPressed: () => delete(),
  isDestructiveAction: true, // Red text
)

// Good: Confirm destructive actions
final confirmed = await IOSAlertDialog.showConfirmation(
  context: context,
  title: 'Delete Item',
  isDestructive: true,
);
```

## Platform-Specific Code

### Conditional UI:
```dart
import 'dart:io';

Widget buildButton() {
  if (Platform.isIOS) {
    return CupertinoButton(
      child: Text('iOS Button'),
      onPressed: () {},
    );
  } else {
    return ElevatedButton(
      child: Text('Material Button'),
      onPressed: () {},
    );
  }
}
```

### Using Platform Widgets:
```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Automatically uses Cupertino on iOS, Material on Android
PlatformSwitch(
  value: value,
  onChanged: (newValue) => setState(() => value = newValue),
)
```

## Accessibility

### VoiceOver Support:
All components support VoiceOver (iOS screen reader):
```dart
Semantics(
  label: 'Enable notifications',
  child: IOSSwitch(
    value: notificationsEnabled,
    onChanged: (value) => setState(() => notificationsEnabled = value),
  ),
)
```

### Reduced Motion:
Respect user's motion preferences:
```dart
final reducedMotion = MediaQuery.of(context).disableAnimations;

if (!reducedMotion) {
  // Show animations
} else {
  // Skip animations
}
```

### Dynamic Type:
Support iOS dynamic type sizing:
```dart
Text(
  'Hello',
  style: CupertinoTheme.of(context).textTheme.textStyle,
)
```

## Performance Tips

### 1. Const Constructors
```dart
// Good: Use const where possible
const IOSLoadingIndicator()

// Avoid: Unnecessary rebuilds
IOSLoadingIndicator()
```

### 2. Haptic Feedback Throttling
```dart
// Good: Throttle rapid haptics
DateTime? lastHaptic;
void onSliderChange(double value) {
  final now = DateTime.now();
  if (lastHaptic == null || 
      now.difference(lastHaptic!) > Duration(milliseconds: 50)) {
    Haptics.vibrate(HapticsType.selection);
    lastHaptic = now;
  }
}
```

### 3. Lazy Loading
```dart
// Good: Lazy load bottom sheets
IOSBottomSheet.show(
  context: context,
  child: Builder(
    builder: (context) => ExpensiveWidget(),
  ),
);
```

## Testing on iOS Simulator

### 1. Run iOS Simulator:
```bash
open -a Simulator
```

### 2. Run Flutter App:
```bash
flutter run -d iPhone
```

### 3. Test Haptic Feedback:
- Simulator doesn't support haptics
- Test on physical device for full experience
- Check console logs for haptic calls

### 4. Test Dark Mode:
- Settings → Developer → Dark Appearance
- Or use simulator menu: Features → Toggle Appearance

### 5. Test Dynamic Type:
- Settings → Accessibility → Display & Text Size → Larger Text

## Troubleshooting

### Issue: Haptic feedback not working
**Solutions:**
- Test on physical device (simulator doesn't support haptics)
- Check device settings: Settings → Sounds & Haptics
- Verify `haptic_feedback` package is installed

### Issue: Components look wrong
**Solutions:**
- Ensure using `CupertinoApp` or `CupertinoTheme`
- Check theme configuration
- Verify imports from `flutter/cupertino.dart`

### Issue: Bottom sheet not dismissing
**Solutions:**
- Check `isDismissible` parameter
- Ensure `enableDrag` is true
- Verify no blocking gestures

### Issue: Context menu not showing
**Solutions:**
- Ensure long-press gesture
- Check for conflicting gesture detectors
- Verify actions list is not empty

## Migration from Material

### Switch to Cupertino:
```dart
// Before (Material)
import 'package:flutter/material.dart';

Scaffold(
  appBar: AppBar(title: Text('Title')),
  body: ListView(
    children: [
      SwitchListTile(
        title: Text('Option'),
        value: value,
        onChanged: (v) => setState(() => value = v),
      ),
    ],
  ),
)

// After (Cupertino)
import 'package:flutter/cupertino.dart';

CupertinoPageScaffold(
  navigationBar: IOSNavigationBar(middle: Text('Title')),
  child: ListView(
    children: [
      IOSToggle(
        label: 'Option',
        value: value,
        onChanged: (v) => setState(() => value = v),
      ),
    ],
  ),
)
```

---

**Status**: ✅ Fully Implemented
**Version**: 1.0.0
**Last Updated**: 2025-10-01
**Team**: Team Narcos

## Quick Reference

| Component | File | Use Case |
|-----------|------|----------|
| IOSBottomSheet | ios_components.dart | Modals, pickers |
| IOSActionSheet | ios_components.dart | Multiple options |
| IOSAlertDialog | ios_components.dart | Alerts, confirmations |
| IOSSwitch | ios_switches.dart | Toggle settings |
| IOSToggle | ios_switches.dart | Settings with labels |
| IOSCheckbox | ios_switches.dart | Multi-select |
| IOSRadio | ios_switches.dart | Single select |
| IOSSlider | ios_switches.dart | Value adjustment |
| IOSSegmentedButton | ios_switches.dart | View modes |
| IOSContextMenu | ios_components.dart | Long-press actions |
| IOSNavigationBar | ios_components.dart | Page navigation |
| IOSLoadingIndicator | ios_components.dart | Loading states |
