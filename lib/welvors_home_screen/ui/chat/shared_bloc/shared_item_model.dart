class SharedItem {
  final String id;
  final String messageType;
  final SharedItemSender? sender;
  final String? mediaUrl;
  final String? content;
  final dynamic metadata;
  final String? createdAt;

  const SharedItem({
    required this.id,
    required this.messageType,
    this.sender,
    this.mediaUrl,
    this.content,
    this.metadata,
    this.createdAt,
  });

  factory SharedItem.fromJson(Map<String, dynamic> json) {
    return SharedItem(
      id: '${json['id'] ?? ''}',
      messageType: '${json['messageType'] ?? ''}'.toUpperCase(),
      sender: json['sender'] is Map
          ? SharedItemSender.fromJson(Map<String, dynamic>.from(json['sender']))
          : null,
      mediaUrl: json['mediaUrl']?.toString(),
      content: json['content']?.toString(),
      metadata: json['metadata'],
      createdAt: json['createdAt']?.toString(),
    );
  }

  String? get fileName {
    final url = mediaUrl;

    if (url == null || url.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(url);

    if (uri == null || uri.path.isEmpty) {
      return null;
    }

    final name = uri.path.split('/').last;

    if (name.isEmpty) {
      return null;
    }

    return Uri.decodeComponent(name);
  }

  String? get fileSize {
    if (metadata is Map) {
      final map = Map<String, dynamic>.from(metadata);

      return map['fileSize']?.toString() ?? map['size']?.toString();
    }

    return null;
  }

  bool get isImage {
    return messageType == 'IMAGE';
  }

  bool get isVideo {
    return messageType == 'VIDEO';
  }

  bool get isAudio {
    return messageType == 'AUDIO';
  }

  bool get isFile {
    return messageType == 'FILE';
  }

  bool get isLink {
    return messageType == 'LINK';
  }
}

class SharedItemSender {
  final String id;
  final String name;
  final String? photo;
  final bool isMe;

  const SharedItemSender({
    required this.id,
    required this.name,
    this.photo,
    required this.isMe,
  });

  factory SharedItemSender.fromJson(Map<String, dynamic> json) {
    return SharedItemSender(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      photo: json['photo']?.toString(),
      isMe: json['isMe'] == true,
    );
  }
}

class SharedItemsBundle {
  final List<SharedItem> media;
  final List<SharedItem> documents;
  final List<SharedItem> links;

  const SharedItemsBundle({
    required this.media,
    required this.documents,
    required this.links,
  });

  List<SharedItem> get all => [...media, ...documents, ...links];

  List<SharedItem> get images =>
      media.where((item) => item.messageType.toUpperCase() == 'IMAGE').toList();

  List<SharedItem> get videos =>
      media.where((item) => item.messageType.toUpperCase() == 'VIDEO').toList();

  List<SharedItem> get audios =>
      media.where((item) => item.messageType.toUpperCase() == 'AUDIO').toList();
}
