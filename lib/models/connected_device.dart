class ConnectedDeviceModel {
  final String name;
  final String lastActive,connectedAt,ip;
  final String language,connectionType,lastAction,version,os;
  final bool mine,active;
  bool trusted;
  final int id;

  ConnectedDeviceModel({
    required this.id,
    required this.name,
    required this.lastActive,
    required this.connectedAt,
    required this.ip,
    required this.language,
    required this.connectionType,
    required this.lastAction,
    required this.version,
    required this.os,
    this.mine = false,
    this.trusted = false,
    this.active = true,
  });

  factory ConnectedDeviceModel.fromMap(Map<String, dynamic> json) =>
      ConnectedDeviceModel(
        id: json['id'],
        name: json['device'] ?? "unknown",
        lastActive: json['last_activity'],
        connectedAt: json['connected_at'],
        ip: json['ip'] ?? "unknown",
        language: json['language'] ?? "unknown",
        connectionType: json['connection_type'] ?? "unknown",
        lastAction: json['last_action'] ?? "unknown",
        version: json['device_version'] ?? "unknown",
        os: json['os'] ?? "unknown",
        mine: json['mine'],
        trusted: json['trusted'],
        active: json['active'],
      );

  Map<String, dynamic> toMap() => {
        'id':id,
        'name': name,
        'lastActive': lastActive,
        'connectedAt': connectedAt,
        'ip': ip,
        'language': language,
        'connectionType': connectionType,
        'lastAction': lastAction,
        'device_version': version,
        'os': os,
        'mine': mine,
        'trusted': trusted,
        'active': active,
      };
}
