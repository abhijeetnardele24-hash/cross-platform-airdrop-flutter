import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS-style bottom sheet with blur effect
class IOSBottomSheet {
  /// Show iOS-style bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    Color? backgroundColor,
    double? height,
    bool enableDrag = true,
  }) async {
    await HapticFeedback.lightImpact();
    
    return showCupertinoModalPopup<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (BuildContext context) {
        return Container(
          height: height ?? MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: backgroundColor ?? CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              if (enableDrag)
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey3.resolveFrom(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }

  /// Show iOS-style action sheet
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<IOSActionSheetAction> actions,
    IOSActionSheetAction? cancelAction,
  }) async {
    await HapticFeedback.lightImpact();
    
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          message: message != null ? Text(message) : null,
          actions: actions.map((action) {
            return CupertinoActionSheetAction(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                action.onPressed();
              },
              isDefaultAction: action.isDefaultAction,
              isDestructiveAction: action.isDestructiveAction,
              child: Text(action.label),
            );
          }).toList(),
          cancelButton: cancelAction != null
              ? CupertinoActionSheetAction(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    cancelAction.onPressed();
                  },
                  child: Text(cancelAction.label),
                )
              : null,
        );
      },
    );
  }

  /// Show iOS-style picker sheet
  static Future<T?> showPickerSheet<T>({
    required BuildContext context,
    required Widget picker,
    String? title,
    VoidCallback? onDone,
  }) async {
    await HapticFeedback.lightImpact();
    
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (title != null)
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      const SizedBox(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onDone?.call();
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              Expanded(child: picker),
            ],
          ),
        );
      },
    );
  }
}

/// Action sheet action model
class IOSActionSheetAction {
  final String label;
  final VoidCallback onPressed;
  final bool isDefaultAction;
  final bool isDestructiveAction;

  IOSActionSheetAction({
    required this.label,
    required this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  });
}

/// iOS-style alert dialog
class IOSAlertDialog {
  /// Show iOS-style alert
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    List<IOSAlertAction>? actions,
  }) async {
    await HapticFeedback.mediumImpact();
    
    return showCupertinoDialog<T>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: title != null ? Text(title) : null,
          content: message != null ? Text(message) : null,
          actions: actions?.map((action) {
            return CupertinoDialogAction(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context, action.value);
                action.onPressed?.call();
              },
              isDefaultAction: action.isDefaultAction,
              isDestructiveAction: action.isDestructiveAction,
              child: Text(action.label),
            );
          }).toList() ?? [
            CupertinoDialogAction(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show iOS-style confirmation dialog
  static Future<bool> showConfirmation({
    required BuildContext context,
    String? title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    await HapticFeedback.mediumImpact();
    
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: title != null ? Text(title) : null,
          content: message != null ? Text(message) : null,
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context, false);
              },
              child: Text(cancelLabel),
            ),
            CupertinoDialogAction(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context, true);
              },
              isDestructiveAction: isDestructive,
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }
}

/// Alert action model
class IOSAlertAction<T> {
  final String label;
  final VoidCallback? onPressed;
  final T? value;
  final bool isDefaultAction;
  final bool isDestructiveAction;

  IOSAlertAction({
    required this.label,
    this.onPressed,
    this.value,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  });
}

/// iOS-style segmented control
class IOSSegmentedControl<T extends Object> extends StatelessWidget {
  final Map<T, Widget> children;
  final T? groupValue;
  final ValueChanged<T>? onValueChanged;
  final Color? selectedColor;
  final Color? unselectedColor;

  const IOSSegmentedControl({
    super.key,
    required this.children,
    this.groupValue,
    this.onValueChanged,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<T>(
      groupValue: groupValue,
      children: children,
      onValueChanged: (T? value) {
        if (value != null) {
          HapticFeedback.lightImpact();
          onValueChanged?.call(value);
        }
      },
      backgroundColor: unselectedColor ?? CupertinoColors.systemGrey5.resolveFrom(context),
      thumbColor: selectedColor ?? CupertinoColors.white,
    );
  }
}

/// iOS-style context menu
class IOSContextMenu extends StatelessWidget {
  final Widget child;
  final List<IOSContextMenuAction> actions;
  final Widget? previewBuilder;

  const IOSContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.previewBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoContextMenu(
      actions: actions.map((action) {
        return CupertinoContextMenuAction(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            action.onPressed();
          },
          isDefaultAction: action.isDefaultAction,
          isDestructiveAction: action.isDestructiveAction,
          trailingIcon: action.icon,
          child: Text(action.label),
        );
      }).toList(),
      child: child,
    );
  }
}

/// Context menu action model
class IOSContextMenuAction {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isDefaultAction;
  final bool isDestructiveAction;

  IOSContextMenuAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  });
}

/// iOS-style loading indicator
class IOSLoadingIndicator extends StatelessWidget {
  final double radius;
  final Color? color;

  const IOSLoadingIndicator({
    super.key,
    this.radius = 10.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      radius: radius,
      color: color,
    );
  }
}

/// iOS-style navigation bar
class IOSNavigationBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final Widget? leading;
  final Widget middle;
  final Widget? trailing;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;

  const IOSNavigationBar({
    super.key,
    this.leading,
    required this.middle,
    this.trailing,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      leading: leading,
      middle: middle,
      trailing: trailing,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(44.0);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    final Color backgroundColor = this.backgroundColor ??
        CupertinoTheme.of(context).barBackgroundColor ??
        CupertinoColors.systemBackground.resolveFrom(context);
    return backgroundColor.alpha == 0xFF;
  }
}
