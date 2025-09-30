import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

/// iOS-style switch with haptic feedback
class IOSSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? trackColor;

  const IOSSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged != null
          ? (bool newValue) {
              Haptics.vibrate(HapticsType.selection);
              onChanged!(newValue);
            }
          : null,
      activeColor: activeColor ?? CupertinoColors.activeGreen,
      trackColor: trackColor,
    );
  }
}

/// iOS-style toggle with label
class IOSToggle extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;
  final Color? activeColor;

  const IOSToggle({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.icon,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return GestureDetector(
      onTap: onChanged != null
          ? () {
              Haptics.vibrate(HapticsType.selection);
              onChanged!(!value);
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? CupertinoColors.darkBackgroundGray
              : CupertinoColors.white,
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: activeColor ?? CupertinoColors.activeBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      color: isDark
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IOSSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: activeColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// iOS-style checkbox (using switch)
class IOSCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const IOSCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null
          ? () {
              Haptics.vibrate(HapticsType.selection);
              onChanged!(!value);
            }
          : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value
              ? (activeColor ?? CupertinoColors.activeBlue)
              : CupertinoColors.systemGrey5.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? (activeColor ?? CupertinoColors.activeBlue)
                : CupertinoColors.systemGrey3.resolveFrom(context),
            width: 2,
          ),
        ),
        child: value
            ? const Icon(
                CupertinoIcons.checkmark,
                size: 16,
                color: CupertinoColors.white,
              )
            : null,
      ),
    );
  }
}

/// iOS-style radio button
class IOSRadio<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final Color? activeColor;

  const IOSRadio({
    super.key,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.activeColor,
  });

  bool get isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null
          ? () {
              Haptics.vibrate(HapticsType.selection);
              onChanged!(value);
            }
          : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? (activeColor ?? CupertinoColors.activeBlue)
              : CupertinoColors.systemGrey5.resolveFrom(context),
          border: Border.all(
            color: isSelected
                ? (activeColor ?? CupertinoColors.activeBlue)
                : CupertinoColors.systemGrey3.resolveFrom(context),
            width: 2,
          ),
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoColors.white,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// iOS-style slider
class IOSSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final Color? activeColor;
  final Color? thumbColor;

  const IOSSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.activeColor,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSlider(
      value: value,
      onChanged: onChanged != null
          ? (double newValue) {
              Haptics.vibrate(HapticsType.selection);
              onChanged!(newValue);
            }
          : null,
      onChangeEnd: onChangeEnd,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: activeColor ?? CupertinoColors.activeBlue,
      thumbColor: thumbColor ?? CupertinoColors.white,
    );
  }
}

/// iOS-style segmented button
class IOSSegmentedButton<T extends Object> extends StatelessWidget {
  final T value;
  final List<IOSSegment<T>> segments;
  final ValueChanged<T>? onChanged;
  final Color? selectedColor;
  final Color? unselectedColor;

  const IOSSegmentedButton({
    super.key,
    required this.value,
    required this.segments,
    this.onChanged,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<T>(
      groupValue: value,
      children: Map.fromEntries(
        segments.map((segment) => MapEntry(
              segment.value,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: segment.child,
              ),
            )),
      ),
      onValueChanged: (T? newValue) {
        if (newValue != null && onChanged != null) {
          Haptics.vibrate(HapticsType.selection);
          onChanged!(newValue);
        }
      },
      backgroundColor: unselectedColor ??
          CupertinoColors.systemGrey5.resolveFrom(context),
      thumbColor: selectedColor ?? CupertinoColors.white,
    );
  }
}

/// Segment model for segmented button
class IOSSegment<T> {
  final T value;
  final Widget child;

  IOSSegment({
    required this.value,
    required this.child,
  });
}

/// iOS-style toggle button group
class IOSToggleButtons extends StatelessWidget {
  final List<bool> isSelected;
  final List<Widget> children;
  final ValueChanged<int>? onPressed;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const IOSToggleButtons({
    super.key,
    required this.isSelected,
    required this.children,
    this.onPressed,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(children.length, (index) {
        final isFirst = index == 0;
        final isLast = index == children.length - 1;
        final selected = isSelected[index];

        return GestureDetector(
          onTap: onPressed != null
              ? () {
                  Haptics.vibrate(HapticsType.selection);
                  onPressed!(index);
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? (selectedColor ?? CupertinoColors.activeBlue)
                  : (unselectedColor ??
                      CupertinoColors.systemGrey5.resolveFrom(context)),
              borderRadius: BorderRadius.horizontal(
                left: isFirst ? const Radius.circular(8) : Radius.zero,
                right: isLast ? const Radius.circular(8) : Radius.zero,
              ),
              border: Border.all(
                color: CupertinoColors.systemGrey3.resolveFrom(context),
                width: 0.5,
              ),
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: selected
                    ? (selectedTextColor ?? CupertinoColors.white)
                    : (unselectedTextColor ??
                        CupertinoColors.label.resolveFrom(context)),
                fontSize: 15,
              ),
              child: children[index],
            ),
          ),
        );
      }),
    );
  }
}
