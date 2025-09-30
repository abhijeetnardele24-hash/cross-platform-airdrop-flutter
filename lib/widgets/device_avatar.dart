import 'package:flutter/material.dart';

class DeviceAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;

  const DeviceAvatar(
      {super.key, required this.name, this.avatarUrl, this.size = 40});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl!),
        radius: size / 2,
      );
    }
    final initials = name.isNotEmpty
        ? name.trim().split(' ').take(2).map((e) => e[0].toUpperCase()).join()
        : '?';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.blueAccent.withOpacity(0.7),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size / 2,
        ),
      ),
    );
  }
}
