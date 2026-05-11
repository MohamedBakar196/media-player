import 'dart:io';

import 'package:path/path.dart' as p;

enum MediaType { video, audio }

class MediaItem {
  const MediaItem({
    required this.path,
    required this.name,
    required this.mediaType,
    required this.createdAt,
    required this.sizeInBytes,
  });

  final String path;
  final String name;
  final MediaType mediaType;
  final DateTime createdAt;
  final int sizeInBytes;

  String get extension => p.extension(path).toLowerCase();

  String get readableSize {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    }
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static Future<MediaItem> fromFile(File file) async {
    final stat = await file.stat();
    final ext = p.extension(file.path).toLowerCase();
    return MediaItem(
      path: file.path,
      name: p.basename(file.path),
      mediaType: _mediaTypeFromExt(ext),
      createdAt: stat.modified,
      sizeInBytes: stat.size,
    );
  }

  static MediaType _mediaTypeFromExt(String ext) {
    const audioExtensions = {'.mp3', '.wav', '.aac', '.m4a', '.ogg', '.flac'};
    return audioExtensions.contains(ext) ? MediaType.audio : MediaType.video;
  }
}
