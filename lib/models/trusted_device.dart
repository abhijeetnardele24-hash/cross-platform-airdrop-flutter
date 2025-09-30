class TrustedDevice {
  final String id;
  final String name;
  final String? avatar;
  final String? fingerprint;
  final DateTime addedAt;
  final bool isApproved;
  final int trustLevel; // 1: low, 2: medium, 3: high
  final DateTime? lastConnected;

  TrustedDevice({
    required this.id,
    required this.name,
    this.avatar,
    this.fingerprint,
    DateTime? addedAt,
    this.isApproved = false,
    this.trustLevel = 1,
    this.lastConnected,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'fingerprint': fingerprint,
        'addedAt': addedAt.toIso8601String(),
        'isApproved': isApproved,
        'trustLevel': trustLevel,
        'lastConnected': lastConnected?.toIso8601String(),
      };

  factory TrustedDevice.fromJson(Map<String, dynamic> json) => TrustedDevice(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        avatar: json['avatar'] ?? json['avatarUrl'], // Backward compatibility
        fingerprint: json['fingerprint'],
        addedAt: json['addedAt'] != null
            ? DateTime.parse(json['addedAt'] as String)
            : DateTime.now(),
        isApproved: json['isApproved'] ?? false,
        trustLevel: json['trustLevel'] ?? 1,
        lastConnected: json['lastConnected'] != null
            ? DateTime.parse(json['lastConnected'] as String)
            : null,
      );
}
