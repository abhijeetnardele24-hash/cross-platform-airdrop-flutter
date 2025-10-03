import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../theme/ios_theme.dart';
import '../../providers/theme_provider.dart';

class IOSComponentsTestScreen extends StatefulWidget {
  const IOSComponentsTestScreen({super.key});

  @override
  State<IOSComponentsTestScreen> createState() => _IOSComponentsTestScreenState();
}

class _IOSComponentsTestScreenState extends State<IOSComponentsTestScreen> {
  bool _switchValue = false;
  double _sliderValue = 0.5;
  int _segmentedValue = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.backgroundColor(isDark),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('iOS Components Test'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Switches', [
              CupertinoListTile(
                title: const Text('Test Switch'),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            _buildSection('Sliders', [
              CupertinoSlider(
                value: _sliderValue,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            _buildSection('Segmented Control', [
              CupertinoSlidingSegmentedControl<int>(
                groupValue: _segmentedValue,
                children: const {
                  0: Text('First'),
                  1: Text('Second'),
                  2: Text('Third'),
                },
                onValueChanged: (value) {
                  setState(() {
                    _segmentedValue = value ?? 0;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            _buildSection('Buttons', [
              CupertinoButton.filled(
                onPressed: () {
                  _showAlert();
                },
                child: const Text('Show Alert'),
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                onPressed: () {
                  _showActionSheet();
                },
                child: const Text('Show Action Sheet'),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            _buildSection('Text Fields', [
              const CupertinoTextField(
                placeholder: 'Enter text here',
                padding: EdgeInsets.all(12),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: IOSTheme.title2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  void _showAlert() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Test Alert'),
        content: const Text('This is a test alert dialog.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showActionSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Test Action Sheet'),
        message: const Text('Choose an action'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Action 1'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoActionSheetAction(
            child: const Text('Action 2'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
