import 'package:flutter/material.dart';
import '../models/room_settings.dart';

class RoomSettingsDialog extends StatefulWidget {
  final void Function(RoomSettings settings) onSave;
  final RoomSettings? initial;
  const RoomSettingsDialog({super.key, required this.onSave, this.initial});

  @override
  State<RoomSettingsDialog> createState() => _RoomSettingsDialogState();
}

class _RoomSettingsDialogState extends State<RoomSettingsDialog> {
  late TextEditingController _expiryController;
  late TextEditingController _passwordController;
  late TextEditingController _maxUsersController;

  @override
  void initState() {
    super.initState();
    _expiryController = TextEditingController(text: widget.initial?.expiryMinutes?.toString() ?? '');
    _passwordController = TextEditingController(text: widget.initial?.password ?? '');
    _maxUsersController = TextEditingController(text: widget.initial?.maxUsers?.toString() ?? '');
  }

  @override
  void dispose() {
    _expiryController.dispose();
    _passwordController.dispose();
    _maxUsersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Room Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _expiryController,
            decoration: const InputDecoration(labelText: 'Room Expiry (minutes)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password (optional)'),
            obscureText: true,
          ),
          TextField(
            controller: _maxUsersController,
            decoration: const InputDecoration(labelText: 'Max Users (optional)'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final settings = RoomSettings(
              expiryMinutes: int.tryParse(_expiryController.text),
              password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
              maxUsers: int.tryParse(_maxUsersController.text),
            );
            widget.onSave(settings);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
