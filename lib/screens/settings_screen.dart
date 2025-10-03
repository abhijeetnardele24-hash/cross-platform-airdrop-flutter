import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/avatar_picker.dart';
import '../theme/ios_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _avatarFile;
  String _username = '';
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
    try {
      final prefs = await SharedPreferences.getInstance();
      _packageInfo = await PackageInfo.fromPlatform();
      
      if (mounted) {
        setState(() {
          _username = prefs.getString('username') ?? '';
          _usernameController.text = _username;
          _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
          _autoAcceptFiles = prefs.getBool('auto_accept_files') ?? false;
          _saveToGallery = prefs.getBool('save_to_gallery') ?? true;
          
          final avatarPath = prefs.getString('avatar_path');
          if (avatarPath != null && File(avatarPath).existsSync()) {
            _avatarFile = File(avatarPath);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveAvatar(File? file) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (file != null) {
        await prefs.setString('avatar_path', file.path);
      } else {
        await prefs.remove('avatar_path');
      }
      if (mounted) {
        setState(() => _avatarFile = file);
      }
    } catch (e) {
      debugPrint('Error saving avatar: $e');
    }
  }

  Future<void> _saveUsername(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', value);
      if (mounted) {
        setState(() => _username = value);
      }
    } catch (e) {
      debugPrint('Error saving username: $e');
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving preference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.backgroundColor(isDark),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSTheme.cardColor(isDark).withValues(alpha: 0.9),
        border: null,
        middle: Text(
          'Settings',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: IOSTheme.primaryTextColor(isDark),
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            IOSTheme.lightImpact();
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.back,
            color: IOSTheme.systemBlue,
            size: 22,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Section
            _buildProfileCard(isDark),
            const SizedBox(height: 24),
            
            // Preferences Section
            _buildPreferencesCard(isDark),
            const SizedBox(height: 24),
            
            // Appearance Section
            _buildAppearanceCard(isDark, themeProvider, localeProvider),
            const SizedBox(height: 24),
            
            // About Section
            _buildAboutCard(isDark),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: IOSTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(IOSTheme.cardRadius),
      ),
      child: Column(
        children: [
          // Avatar
          Center(
            child: AvatarPicker(
              initialAvatar: _avatarFile,
              onAvatarChanged: _saveAvatar,
            ),
          ),
          const SizedBox(height: 16),
          
          // Username display
          Text(
            _username.isEmpty ? 'Set your username' : _username,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: IOSTheme.primaryTextColor(isDark),
            ),
          ),
          const SizedBox(height: 20),
          
          // Username input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: IOSTheme.separatorColor(isDark).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.person,
                  color: IOSTheme.systemBlue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoTextField(
                    controller: _usernameController,
                    placeholder: 'Enter your username',
                    decoration: const BoxDecoration(),
                    style: TextStyle(
                      color: IOSTheme.primaryTextColor(isDark),
                      fontSize: 16,
                    ),
                    onChanged: _saveUsername,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: IOSTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(IOSTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IOSSectionHeader(title: 'Preferences', isDark: isDark),
          IOSListTile(
            leadingIcon: CupertinoIcons.bell,
            title: 'Notifications',
            subtitle: 'File transfer alerts',
            isDark: isDark,
            trailing: CupertinoSwitch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _savePreference('notifications_enabled', value);
              },
            ),
          ),
          IOSDivider(isDark: isDark),
          IOSListTile(
            leadingIcon: CupertinoIcons.download_circle,
            title: 'Auto Accept Files',
            subtitle: 'Accept files automatically',
            isDark: isDark,
            trailing: CupertinoSwitch(
              value: _autoAcceptFiles,
              onChanged: (value) {
                setState(() => _autoAcceptFiles = value);
                _savePreference('auto_accept_files', value);
              },
            ),
          ),
          IOSDivider(isDark: isDark),
          IOSListTile(
            leadingIcon: CupertinoIcons.photo,
            title: 'Save to Gallery',
            subtitle: 'Save images to gallery',
            isDark: isDark,
            trailing: CupertinoSwitch(
              value: _saveToGallery,
              onChanged: (value) {
                setState(() => _saveToGallery = value);
                _savePreference('save_to_gallery', value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(bool isDark, ThemeProvider themeProvider, LocaleProvider localeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: IOSTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(IOSTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IOSSectionHeader(title: 'Appearance', isDark: isDark),
          IOSListTile(
            leadingIcon: isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
            title: 'Dark Mode',
            subtitle: isDark ? 'Dark theme active' : 'Light theme active',
            isDark: isDark,
            trailing: CupertinoSwitch(
              value: isDark,
              onChanged: (value) {
                themeProvider.setBrightness(
                  value ? Brightness.dark : Brightness.light,
                );
              },
            ),
          ),
          IOSDivider(isDark: isDark),
          IOSListTile(
            leadingIcon: CupertinoIcons.globe,
            title: 'Language',
            subtitle: localeProvider.locale.languageCode == 'hi' ? 'हिन्दी' : 'English',
            isDark: isDark,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showLanguagePicker(localeProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: IOSTheme.systemBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  localeProvider.locale.languageCode == 'hi' ? 'हिन्दी' : 'English',
                  style: const TextStyle(
                    color: IOSTheme.systemBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: IOSTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(IOSTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IOSSectionHeader(title: 'About', isDark: isDark),
          IOSListTile(
            leadingIcon: CupertinoIcons.info_circle,
            title: 'About App',
            subtitle: 'Version ${_packageInfo?.version ?? '1.0.0'}',
            isDark: isDark,
            trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
            onTap: _showAboutDialog,
          ),
          IOSDivider(isDark: isDark),
          IOSListTile(
            leadingIcon: CupertinoIcons.lock_shield,
            title: 'Privacy Policy',
            isDark: isDark,
            trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
            onTap: () {
              // Show Cupertino dialog instead of SnackBar
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Privacy Policy'),
                  content: const Text('Privacy Policy coming soon'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
          IOSDivider(isDark: isDark),
          IOSListTile(
            leadingIcon: CupertinoIcons.doc_text,
            title: 'Terms of Service',
            isDark: isDark,
            trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
            onTap: () {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Terms of Service'),
                  content: const Text('Terms of Service coming soon'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  void _showLanguagePicker(LocaleProvider localeProvider) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: localeProvider.locale.languageCode == 'hi' ? 1 : 0,
            ),
            onSelectedItemChanged: (int selectedItem) {
              final locale = selectedItem == 0 ? const Locale('en') : const Locale('hi');
              localeProvider.setLocale(locale);
            },
            children: const [
              Center(child: Text('English')),
              Center(child: Text('हिन्दी')),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('About Cross-Platform Airdrop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Version: ${_packageInfo?.version ?? '1.0.0'}'),
            const SizedBox(height: 8),
            const Text('A modern file sharing app for cross-platform devices.'),
            const SizedBox(height: 8),
            const Text('Developed by Team Narcos'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
