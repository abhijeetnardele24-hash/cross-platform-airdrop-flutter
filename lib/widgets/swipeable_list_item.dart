import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

/// iOS-style swipeable list item with delete action
class SwipeableListItem extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onShare;
  final Color deleteColor;
  final Color archiveColor;
  final Color shareColor;
  final bool confirmDelete;
  final String? deleteConfirmTitle;
  final String? deleteConfirmMessage;

  const SwipeableListItem({
    super.key,
    required this.child,
    this.onDelete,
    this.onArchive,
    this.onShare,
    this.deleteColor = Colors.red,
    this.archiveColor = Colors.orange,
    this.shareColor = Colors.blue,
    this.confirmDelete = true,
    this.deleteConfirmTitle,
    this.deleteConfirmMessage,
  });

  @override
  State<SwipeableListItem> createState() => _SwipeableListItemState();
}

class _SwipeableListItemState extends State<SwipeableListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  double _dragExtent = 0;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    if (widget.confirmDelete) {
      final confirmed = await _showDeleteConfirmation();
      if (!confirmed) {
        _controller.reverse();
        return;
      }
    }

    setState(() => _isDeleting = true);
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    
    Haptics.vibrate(HapticsType.success);
    widget.onDelete?.call();
  }

  Future<bool> _showDeleteConfirmation() async {
    Haptics.vibrate(HapticsType.warning);

    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(widget.deleteConfirmTitle ?? 'Delete Item'),
        content: Text(
          widget.deleteConfirmMessage ??
              'Are you sure you want to delete this item?',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Haptics.vibrate(HapticsType.selection);
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Haptics.vibrate(HapticsType.selection);
              Navigator.pop(context, true);
            },
            isDestructiveAction: true,
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeleting) {
      return const SizedBox.shrink();
    }

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (widget.onDelete != null) {
          await _handleDelete();
          return false; // We handle the deletion manually
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: widget.deleteColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          CupertinoIcons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Advanced swipeable item with multiple actions
class AdvancedSwipeableItem extends StatefulWidget {
  final Widget child;
  final List<SwipeAction> leftActions;
  final List<SwipeAction> rightActions;
  final double actionExtentRatio;

  const AdvancedSwipeableItem({
    super.key,
    required this.child,
    this.leftActions = const [],
    this.rightActions = const [],
    this.actionExtentRatio = 0.25,
  });

  @override
  State<AdvancedSwipeableItem> createState() => _AdvancedSwipeableItemState();
}

class _AdvancedSwipeableItemState extends State<AdvancedSwipeableItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta ?? 0;
      _dragExtent = _dragExtent.clamp(-200.0, 200.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragExtent.abs() > 80) {
      Haptics.vibrate(HapticsType.selection);
      
      if (_dragExtent > 0 && widget.leftActions.isNotEmpty) {
        widget.leftActions.first.onPressed();
      } else if (_dragExtent < 0 && widget.rightActions.isNotEmpty) {
        widget.rightActions.first.onPressed();
      }
    }

    setState(() {
      _dragExtent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // Background actions
          if (_dragExtent != 0) _buildBackground(),
          
          // Main content
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (_dragExtent > 0 && widget.leftActions.isNotEmpty) {
      return Positioned.fill(
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16),
          color: widget.leftActions.first.color,
          child: Icon(
            widget.leftActions.first.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    } else if (_dragExtent < 0 && widget.rightActions.isNotEmpty) {
      return Positioned.fill(
        child: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          color: widget.rightActions.first.color,
          child: Icon(
            widget.rightActions.first.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Swipe action model
class SwipeAction {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String? label;

  SwipeAction({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.label,
  });
}

/// iOS-style slideable action
class SlidableListItem extends StatelessWidget {
  final Widget child;
  final List<SlidableAction> actions;
  final double actionExtent;

  const SlidableListItem({
    super.key,
    required this.child,
    required this.actions,
    this.actionExtent = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Show actions instead of dismissing
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions.map((action) {
            return GestureDetector(
              onTap: () {
                Haptics.vibrate(HapticsType.selection);
                action.onPressed();
              },
              child: Container(
                width: actionExtent,
                color: action.color,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                    if (action.label != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        action.label!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      child: child,
    );
  }
}

/// Slidable action model
class SlidableAction {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String? label;

  SlidableAction({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.label,
  });
}
