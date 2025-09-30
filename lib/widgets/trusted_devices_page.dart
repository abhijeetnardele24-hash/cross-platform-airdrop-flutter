import 'package:flutter/material.dart';
import '../models/trusted_device.dart';
import '../services/trusted_device_service.dart';
import 'device_avatar.dart';

class TrustedDevicesPage extends StatefulWidget {
  const TrustedDevicesPage({super.key});
  @override
  State<TrustedDevicesPage> createState() => _TrustedDevicesPageState();
}

class _TrustedDevicesPageState extends State<TrustedDevicesPage> {
  List<TrustedDevice> _devices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _devices = await TrustedDeviceService().getTrustedDevices();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trusted Devices')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
              ? const Center(child: Text('No trusted devices yet.'))
              : ListView.separated(
                  itemCount: _devices.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final d = _devices[i];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading:
                            DeviceAvatar(name: d.name, avatarUrl: d.avatar),
                        title: Text(d.name),
                        subtitle: Text('Added: ${d.addedAt.toLocal()}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await TrustedDeviceService()
                                .removeTrustedDevice(d.id);
                            _load();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
