enum DeviceType {
  android,
  ios,
  windows,
  macos,
  linux,
  unknown;

  String get displayName {
    switch (this) {
      case DeviceType.android:
        return 'Android';
      case DeviceType.ios:
        return 'iOS';
      case DeviceType.windows:
        return 'Windows';
      case DeviceType.macos:
        return 'macOS';
      case DeviceType.linux:
        return 'Linux';
      case DeviceType.unknown:
        return 'Unknown Device';
    }
  }
}

class DeviceModel {
  final String id;
  final String name;
  final DeviceType type;
  final bool isOnline;
  final String ipAddress;
  final DateTime lastSeen;

  DeviceModel({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.type,
    this.isOnline = false,
    required this.lastSeen,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: DeviceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => DeviceType.unknown,
      ),
      isOnline: json['isOnline'] as bool? ?? false,
      ipAddress: json['ipAddress'] as String? ?? '',
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'isOnline': isOnline,
      'ipAddress': ipAddress,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  DeviceModel copyWith({
    String? id,
    String? name,
    DeviceType? type,
    bool? isOnline,
    String? ipAddress,
    DateTime? lastSeen,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isOnline: isOnline ?? this.isOnline,
      ipAddress: ipAddress ?? this.ipAddress,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DeviceModel(id: $id, name: $name, type: $type, isOnline: $isOnline, ipAddress: $ipAddress, lastSeen: $lastSeen)';
  }
}
