import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/avatar_picker.dart';
import '../utils/webrtc_test.dart';
import '../utils/nearby_test.dart';
import 'animation_test_screen.dart';
import 'ios_components_test_screen.dart';
import 'advanced_ui_test_screen.dart';
import '../utils/page_transitions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _avatarFile;
  String? _username;
  late TextEditingController _usernameController;
  bool _notificationsEnabled = true;
  bool _autoAcceptFiles = false;
  bool _saveToGallery = true;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
      _usernameController.text = _username ?? '';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _autoAcceptFiles = prefs.getBool('auto_accept_files') ?? false;
      _saveToGallery = prefs.getBool('save_to_gallery') ?? true;
      final avatarPath = prefs.getString('avatar_path');
      if (avatarPath != null) {
        _avatarFile = File(avatarPath);
      }
    });
    _packageInfo = await PackageInfo.fromPlatform();
    if (mounted) setState(() {});
  }

  void _saveAvatar(File? file) async {
    final prefs = await SharedPreferences.getInstance();
    if (file != null) {
      await prefs.setString('avatar_path', file.path);
    } else {
      await prefs.remove('avatar_path');
    }
    if (mounted) {
      setState(() {
        _avatarFile = file;
      });
    }
  }

  void _saveUsername(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', value);
    if (mounted) {
      setState(() {
        _username = value;
      });
    }
  }

  void _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('About Cross-Platform Airdrop'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Version: ${_packageInfo?.version ?? '1.0.0'}'),
              const SizedBox(height: 8),
              const Text('A modern file sharing app for cross-platform devices.'),
              const SizedBox(height: 8),
              const Text('Developed by Team Narcos'),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Settings'),
      ),
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
            // Profile Section
            _buildSection(
              context,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Semantics(
                          label: 'Profile avatar, tap to change',
                          child: Tooltip(
                            message: 'Change your profile avatar',
                            child: AvatarPicker(
                              initialAvatar: _avatarFile,
                              onAvatarChanged: _saveAvatar,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _username ?? 'Set your username',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Username',
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: TextField(
                      controller: _usernameController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter name',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: _saveUsername,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // Appearance Section
            _buildSectionHeader(context, 'APPEARANCE'),
            _buildSection(
              context,
              children: [
                _buildSwitchTile(
                  context: context,
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  title: 'Dark Mode',
                  value: isDark,
                  onChanged: (val) => themeProvider.toggleTheme(),
                ),
                _buildDivider(),
                _buildListTile(
                  context: context,
                  icon: Icons.language,
                  title: 'Language',
                  trailing: defaultTargetPlatform == TargetPlatform.iOS
                      ? GestureDetector(
                          onTap: () async {
                            Locale? selected = await showCupertinoModalPopup<Locale>(
                              context: context,
                              builder: (context) {
                                int initialIndex = localeProvider.locale.languageCode == 'hi' ? 1 : 0;
                                return Container(
                                  height: 250,
                                  color: CupertinoColors.systemBackground.resolveFrom(context),
                                  child: CupertinoPicker(
                                    scrollController: FixedExtentScrollController(initialItem: initialIndex),
                                    itemExtent: 40,
                                    onSelectedItemChanged: (i) {
                                      final locale = [Locale('en'), Locale('hi')][i];
                                      localeProvider.setLocale(locale);
                                      Navigator.of(context).pop(locale);
                                    },
                                    children: const [
                                      Center(child: Text('English')),
                                      Center(child: Text('हिन्दी')),
                                    ],
                                  ),
                                );
                              },
                            );
                            if (selected != null) localeProvider.setLocale(selected);
                          },
                          child: Text(
                            localeProvider.locale.languageCode == 'hi' ? 'हिन्दी' : 'English',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : DropdownButton<Locale>(
                          value: localeProvider.locale,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: Locale('en'),
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: Locale('hi'),
                              child: Text('हिन्दी'),
                            ),
                          ],
                          onChanged: (locale) {
                            if (locale != null) {
                              localeProvider.setLocale(locale);
                            }
                          },
                        ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // Preferences Section
            _buildSectionHeader(context, 'PREFERENCES'),
            _buildSection(
              context,
              children: [
                _buildSwitchTile(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Receive transfer notifications',
                  value: _notificationsEnabled,
                  onChanged: (val) {
                    setState(() => _notificationsEnabled = val);
                    _savePreference('notifications_enabled', val);
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  context: context,
                  icon: Icons.download_outlined,
                  title: 'Auto-accept Files',
                  subtitle: 'Automatically accept incoming files',
                  value: _autoAcceptFiles,
                  onChanged: (val) {
                    setState(() => _autoAcceptFiles = val);
                    _savePreference('auto_accept_files', val);
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  context: context,
                  icon: Icons.photo_library_outlined,
                  title: 'Save to Gallery',
                  subtitle: 'Save images to photo gallery',
                  value: _saveToGallery,
                  onChanged: (val) {
                    setState(() => _saveToGallery = val);
                    _savePreference('save_to_gallery', val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 35),

            // About Section
            _buildSectionHeader(context, 'ABOUT'),
            _buildSection(
              context,
              children: [
                _buildListTile(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'About App',
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: _showAboutDialog,
                ),
                _buildDivider(),
                _buildListTile(
                  context: context,
                  icon: Icons.article_outlined,
                  title: 'Version',
                  trailing: Text(
                    _packageInfo?.version ?? '1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                ),
                _buildDivider(),
                _buildListTile(
                  context: context,
                  icon: Icons.code,
                  title: 'Developer',
                  trailing: Text(
                    'Team Narcos',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // Developer Tools Section
            _buildSectionHeader(context, 'DEVELOPER TOOLS'),
            _buildSection(
              context,
              children: [
                _buildListTile(
                  context: context,
                  icon: Icons.science_outlined,
                  title: 'Test WebRTC Connection',
                  subtitle: 'Verify P2P connectivity',
                  trailing: const Icon(Icons.play_arrow, size: 20),
                  onTap: () => WebRTCTest.showTestDialog(context),
                ),
                _buildDivider(),
                _buildListTile(
                  context: context,
                  icon: Icons.bug_report_outlined,
                  title: 'Run Monitoring Test',
                  subtitle: 'Monitor connection states',
                  trailing: const Icon(Icons.play_arrow, size: 20),
                  onTap: () {
                    WebRTCTest.testConnectionWithMonitoring();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Monitoring test started. Check console for logs.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context: context,
                  icon: Icons.wifi_tethering,
                  title: 'Test Nearby Connections',
                  subtitle: 'Android/iOS P2P connectivity',
                  trailing: const Icon(Icons.play_arrow, size: 20),
                  onTap: () => NearbyTest.showTestDialog(context),
                ),
                _buildDivider(),
                _buildListTile(
                  context: context,
                  icon: Icons.animation,
                  title: 'Animation Showcase',
                  subtitle: 'Test all animations & transitions',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      PageTransitions.cupertinoRoute(
                          const AnimationTestScreen()),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context: context,
                  icon: Icons.phone_iphone,
                  title: 'iOS Components',
                  subtitle: 'Cupertino widgets & haptic feedback',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      PageTransitions.cupertinoRoute(
                          const IOSComponentsTestScreen()),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context: context,
                  icon: Icons.auto_awesome,
                  title: 'Advanced UI Features',
                  subtitle: 'Thumbnails, drag-drop, swipe, notifications',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      PageTransitions.cupertinoRoute(
                          const AdvancedUITestScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 35),

            // Legal Section
            _buildSectionHeader(context, 'LEGAL'),
            _buildSection(
              context,
              children: [
                _buildListTile(
                  context: context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    // Add privacy policy link
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Privacy Policy coming soon')),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context: context,
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Terms of Service coming soon')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 50),
          ], // Closes ListView children
        ), // Closes ListView
      ), // Closes Material
    ); // Closes SafeArea
  } // Closes build method

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,  // Add required context parameter
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      leading: icon != null ? Icon(icon, color: isDark ? Colors.white70 : Colors.grey[600]) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,  // Add required context parameter
    required String title,
    String? subtitle,
    IconData? icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      leading: icon != null ? Icon(icon, color: isDark ? Colors.white70 : Colors.grey[600]) : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 56,
      thickness: 0.5,
    );
  }
}
