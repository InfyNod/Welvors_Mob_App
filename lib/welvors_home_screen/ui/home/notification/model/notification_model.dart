class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final NotificationSender? sender;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.isRead,
    this.readAt,
    this.createdAt,
    this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : <String, dynamic>{},
      isRead: json['isRead'] == true,
      readAt: _parseDate(json['readAt']),
      createdAt: _parseDate(json['createdAt']),
      sender: json['sender'] is Map
          ? NotificationSender.fromJson(
              Map<String, dynamic>.from(json['sender']),
            )
          : null,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }
}

class NotificationSender {
  final String id;
  final String name;
  final DateTime? birthDate;
  final String? photo;

  const NotificationSender({
    required this.id,
    required this.name,
    this.birthDate,
    this.photo,
  });

  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      birthDate: DateTime.tryParse(json['birthDate']?.toString() ?? ''),
      photo: json['photo']?.toString(),
    );
  }
}
