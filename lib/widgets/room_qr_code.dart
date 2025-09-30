import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RoomQRCode extends StatelessWidget {
  final String roomCode;
  final String? password;
  const RoomQRCode({super.key, required this.roomCode, this.password});

  @override
  Widget build(BuildContext context) {
    final qrData = password == null || password!.isEmpty
        ? roomCode
        : '$roomCode|pw:$password';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 160,
        ),
        const SizedBox(height: 8),
        Text('Room Code: $roomCode', style: const TextStyle(fontWeight: FontWeight.bold)),
        if (password != null && password!.isNotEmpty)
          Text('Password: $password', style: const TextStyle(color: Colors.red)),
      ],
    );
  }
}
