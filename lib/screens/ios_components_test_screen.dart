import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/ios_components.dart';
import '../widgets/ios_switches.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

/// Screen to test all iOS components
class IOSComponentsTestScreen extends StatefulWidget {
  const IOSComponentsTestScreen({super.key});

  @override
  State<IOSComponentsTestScreen> createState() => _IOSComponentsTestScreenState();
}

class _IOSComponentsTestScreenState extends State<IOSComponentsTestScreen> {
  bool _switchValue = false;
  bool _toggle1 = true;
  bool _toggle2 = false;
  bool _checkbox1 = false;
  bool _checkbox2 = true;
  String _radioValue = 'option1';
  double _sliderValue = 0.5;
  int _segmentedValue = 0;
  List<bool> _toggleButtons = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const IOSNavigationBar(
        middle: Text('iOS Components'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            _buildSection('Switches & Toggles'),
            _buildSwitchDemo(),
            _buildToggleDemo(),
            
            _buildSection('Checkboxes & Radio'),
            _buildCheckboxDemo(),
            _buildRadioDemo(),
            
            _buildSection('Sliders & Segments'),
            _buildSliderDemo(),
            _buildSegmentedDemo(),
            
            _buildSection('Bottom Sheets & Dialogs'),
            _buildBottomSheetDemo(),
            _buildActionSheetDemo(),
            _buildAlertDemo(),
            
            _buildSection('Context Menu'),
            _buildContextMenuDemo(),
            
            _buildSection('Loading Indicators'),
            _buildLoadingDemo(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
          letterSpacing: -0.08,
        ),
      ),
    );
  }

  Widget _buildSwitchDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildListTile(
            title: 'iOS Switch',
            subtitle: 'Native Cupertino switch',
            trailing: IOSSwitch(
              value: _switchValue,
              onChanged: (value) => setState(() => _switchValue = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          IOSToggle(
            label: 'Notifications',
            subtitle: 'Receive push notifications',
            value: _toggle1,
            onChanged: (value) => setState(() => _toggle1 = value),
            icon: CupertinoIcons.bell_fill,
            activeColor: CupertinoColors.activeGreen,
          ),
          IOSToggle(
            label: 'Dark Mode',
            subtitle: 'Use dark appearance',
            value: _toggle2,
            onChanged: (value) => setState(() => _toggle2 = value),
            icon: CupertinoIcons.moon_fill,
            activeColor: CupertinoColors.systemIndigo,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IOSCheckbox(
                value: _checkbox1,
                onChanged: (value) => setState(() => _checkbox1 = value),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Accept terms and conditions')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IOSCheckbox(
                value: _checkbox2,
                onChanged: (value) => setState(() => _checkbox2 = value),
                activeColor: CupertinoColors.systemGreen,
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Subscribe to newsletter')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select an option:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildRadioOption('option1', 'Option 1'),
          const SizedBox(height: 8),
          _buildRadioOption('option2', 'Option 2'),
          const SizedBox(height: 8),
          _buildRadioOption('option3', 'Option 3'),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String value, String label) {
    return GestureDetector(
      onTap: () => setState(() => _radioValue = value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          IOSRadio<String>(
            value: value,
            groupValue: _radioValue,
            onChanged: (value) => setState(() => _radioValue = value),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSliderDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Volume', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${(_sliderValue * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 8),
          IOSSlider(
            value: _sliderValue,
            onChanged: (value) => setState(() => _sliderValue = value),
            min: 0.0,
            max: 1.0,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('View Mode', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          IOSSegmentedButton<int>(
            value: _segmentedValue,
            segments: [
              IOSSegment(value: 0, child: const Text('List')),
              IOSSegment(value: 1, child: const Text('Grid')),
              IOSSegment(value: 2, child: const Text('Card')),
            ],
            onChanged: (value) => setState(() => _segmentedValue = value),
          ),
          const SizedBox(height: 16),
          const Text('Toggle Buttons', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          IOSToggleButtons(
            isSelected: _toggleButtons,
            children: const [
              Icon(CupertinoIcons.bold, size: 18),
              Icon(CupertinoIcons.italic, size: 18),
              Icon(CupertinoIcons.underline, size: 18),
            ],
            onPressed: (index) {
              setState(() {
                _toggleButtons[index] = !_toggleButtons[index];
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton(
        color: CupertinoColors.activeBlue,
        onPressed: () {
          IOSBottomSheet.show(
            context: context,
            child: _buildBottomSheetContent(),
            height: 400,
          );
        },
        child: const Text('Show Bottom Sheet'),
      ),
    );
  }

  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bottom Sheet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'This is an iOS-style bottom sheet with a drag handle. '
            'You can swipe down to dismiss it.',
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () {
              Haptics.vibrate(HapticsType.success);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSheetDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoButton(
        color: CupertinoColors.systemGreen,
        onPressed: () {
          IOSBottomSheet.showActionSheet(
            context: context,
            title: 'Choose an action',
            message: 'Select one of the options below',
            actions: [
              IOSActionSheetAction(
                label: 'Share',
                onPressed: () {
                  Haptics.vibrate(HapticsType.success);
                },
                isDefaultAction: true,
              ),
              IOSActionSheetAction(
                label: 'Save',
                onPressed: () {
                  Haptics.vibrate(HapticsType.success);
                },
              ),
              IOSActionSheetAction(
                label: 'Delete',
                onPressed: () {
                  Haptics.vibrate(HapticsType.warning);
                },
                isDestructiveAction: true,
              ),
            ],
            cancelAction: IOSActionSheetAction(
              label: 'Cancel',
              onPressed: () {},
            ),
          );
        },
        child: const Text('Show Action Sheet'),
      ),
    );
  }

  Widget _buildAlertDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoButton(
        color: CupertinoColors.systemOrange,
        onPressed: () async {
          final confirmed = await IOSAlertDialog.showConfirmation(
            context: context,
            title: 'Confirm Action',
            message: 'Are you sure you want to proceed?',
            confirmLabel: 'Yes',
            cancelLabel: 'No',
          );
          
          if (confirmed && mounted) {
            Haptics.vibrate(HapticsType.success);
            IOSAlertDialog.show(
              context: context,
              title: 'Success',
              message: 'Action confirmed!',
            );
          }
        },
        child: const Text('Show Alert'),
      ),
    );
  }

  Widget _buildContextMenuDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: IOSContextMenu(
        actions: [
          IOSContextMenuAction(
            label: 'Copy',
            onPressed: () {
              Haptics.vibrate(HapticsType.success);
            },
            icon: CupertinoIcons.doc_on_doc,
          ),
          IOSContextMenuAction(
            label: 'Share',
            onPressed: () {
              Haptics.vibrate(HapticsType.success);
            },
            icon: CupertinoIcons.share,
          ),
          IOSContextMenuAction(
            label: 'Delete',
            onPressed: () {
              Haptics.vibrate(HapticsType.warning);
            },
            icon: CupertinoIcons.delete,
            isDestructiveAction: true,
          ),
        ],
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(CupertinoIcons.hand_point_left_fill, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Long press me for context menu',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              IOSLoadingIndicator(),
              SizedBox(height: 8),
              Text('Small', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            children: [
              IOSLoadingIndicator(radius: 15),
              SizedBox(height: 8),
              Text('Medium', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            children: [
              IOSLoadingIndicator(radius: 20),
              SizedBox(height: 8),
              Text('Large', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Container(
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 17),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
