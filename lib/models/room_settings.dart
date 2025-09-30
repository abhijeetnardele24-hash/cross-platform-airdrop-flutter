class RoomSettings {
  int? expiryMinutes;
  String? password;
  int? maxUsers;

  RoomSettings({this.expiryMinutes, this.password, this.maxUsers});

  Map<String, dynamic> toJson() => {
    'expiryMinutes': expiryMinutes,
    'password': password,
    'maxUsers': maxUsers,
  };

  factory RoomSettings.fromJson(Map<String, dynamic> json) => RoomSettings(
    expiryMinutes: json['expiryMinutes'],
    password: json['password'],
    maxUsers: json['maxUsers'],
  );
}
