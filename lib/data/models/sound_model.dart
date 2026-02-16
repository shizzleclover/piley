class Sound {
  final String id;
  final String title;
  final String filePath; // URL for remote, unused for local-only?
  final String? localPath; // For offline
  final String uploaderId;
  final String? uploaderName; // New field
  final int playCount;
  final DateTime createdAt;

  Sound({
    required this.id,
    required this.title,
    required this.filePath,
    this.localPath,
    required this.uploaderId,
    this.uploaderName,
    this.playCount = 0,
    required this.createdAt,
  });

  factory Sound.fromMap(Map<String, dynamic> map) {
    return Sound(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Untitled',
      filePath: map['file_path'] ?? '',
      localPath: map['localPath'],
      uploaderId: map['uploader_id'] ?? 'anonymous',
      uploaderName: map['uploader_name'],
      playCount: map['play_count']?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'localPath': localPath,
      'uploader_id': uploaderId,
      'play_count': playCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
