import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../theme/ios_theme.dart';
import '../../providers/theme_provider.dart';

class AdvancedUITestScreen extends StatefulWidget {
  const AdvancedUITestScreen({super.key});

  @override
  State<AdvancedUITestScreen> createState() => _AdvancedUITestScreenState();
}

class _AdvancedUITestScreenState extends State<AdvancedUITestScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.backgroundColor(isDark),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Advanced UI Test'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Cards', [
                _buildTestCard('Test Card 1', isDark),
                _buildTestCard('Test Card 2', isDark),
              ]),
              
              const SizedBox(height: 24),
              
              _buildSection('Buttons', [
                _buildTestButton('Primary Button', IOSTheme.systemBlue),
                _buildTestButton('Secondary Button', IOSTheme.systemGreen),
              ]),
              
              const SizedBox(height: 24),
              
              _buildSection('Lists', [
                _buildTestListTile('List Item 1', CupertinoIcons.home, isDark),
                _buildTestListTile('List Item 2', CupertinoIcons.settings, isDark),
              ]),
            ],
          ),
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

  Widget _buildTestCard(String title, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IOSTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        title,
        style: IOSTheme.body.copyWith(
          color: IOSTheme.primaryTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        color: color,
        onPressed: () {},
        child: Text(title),
      ),
    );
  }

  Widget _buildTestListTile(String title, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: IOSTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CupertinoListTile(
        leading: Icon(icon, color: IOSTheme.systemBlue),
        title: Text(title),
        trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
        onTap: () {},
      ),
    );
  }
}
