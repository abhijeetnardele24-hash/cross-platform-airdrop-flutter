import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRShareWidget extends StatelessWidget {
  final String data;
  final String? label;
  const QRShareWidget({super.key, required this.data, this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
        ],
        Semantics(
          label: 'QR code for file sharing',
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: 'Session code: $data',
          child: SelectableText(
            data,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
