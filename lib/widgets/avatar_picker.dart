import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AvatarPicker extends StatefulWidget {
  final File? initialAvatar;
  final ValueChanged<File?> onAvatarChanged;
  const AvatarPicker({super.key, this.initialAvatar, required this.onAvatarChanged});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  File? _avatar;

  @override
  void initState() {
    super.initState();
    _avatar = widget.initialAvatar;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _avatar = File(picked.path));
      widget.onAvatarChanged(_avatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickAvatar,
      child: CircleAvatar(
        radius: 36,
        backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
        child: _avatar == null ? const Icon(Icons.person, size: 36) : null,
      ),
    );
  }
}
