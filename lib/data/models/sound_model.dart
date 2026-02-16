class Sound {
  final String id;
  final String title;
  final String filePath;
  final String? localPath; // For offline playback
  final String uploaderId;
  final int playCount;
  final DateTime createdAt;

  Sound({
    required this.id,
    required this.title,
    required this.filePath,
    this.localPath,
    required this.uploaderId,
    required this.playCount,
    required this.createdAt,
  });

  factory Sound.fromMap(Map<String, dynamic> map) {
    return Sound(
      id: map['id'].toString(),
      title: map['title'].toString(),
      filePath: map['file_path'].toString(),
      localPath: map['localPath']?.toString(), // Nullable
      uploaderId: map['uploader_id'].toString(),
      playCount: (map['play_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'].toString()),
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
