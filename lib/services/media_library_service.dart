import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/media_item.dart';

class MediaLibraryService {
  MediaLibraryService._();

  static final MediaLibraryService instance = MediaLibraryService._();

  final ValueNotifier<List<MediaItem>> items = ValueNotifier<List<MediaItem>>(
    <MediaItem>[],
  );

  Directory? _mediaDirectory;

  Future<void> initialize() async {
    await _ensureDirectory();
    await scanLibrary();
  }

  Future<Directory> _ensureDirectory() async {
    if (_mediaDirectory != null) {
      return _mediaDirectory!;
    }
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'media'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _mediaDirectory = dir;
    return dir;
  }

  Future<void> scanLibrary() async {
    final dir = await _ensureDirectory();
    final entities = dir
        .listSync()
        .whereType<File>()
        .where(
          (file) => _supportedExtensions.contains(
            p.extension(file.path).toLowerCase(),
          ),
        )
        .toList();

    final loadedItems = <MediaItem>[];
    for (final file in entities) {
      loadedItems.add(await MediaItem.fromFile(file));
    }

    loadedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    items.value = loadedItems;
  }

  int get totalSizeInBytes => items.value.fold<int>(
    0,
    (int total, MediaItem item) => total + item.sizeInBytes,
  );

  int get audioCount => items.value
      .where((MediaItem item) => item.mediaType == MediaType.audio)
      .length;

  int get videoCount => items.value
      .where((MediaItem item) => item.mediaType == MediaType.video)
      .length;

  MediaItem? get newestItem {
    if (items.value.isEmpty) {
      return null;
    }
    return items.value.first;
  }

  Future<MediaItem> addFile(File file, {String? preferredName}) async {
    final dir = await _ensureDirectory();
    final extension = p.extension(file.path).toLowerCase();
    final base = preferredName == null
        ? p.basenameWithoutExtension(file.path)
        : p.basenameWithoutExtension(preferredName);
    final target = await _nextAvailableFile(dir.path, base, extension);
    final copied = await file.copy(target.path);
    final item = await MediaItem.fromFile(copied);
    items.value = <MediaItem>[
      item,
      ...items.value.where((existing) => existing.path != item.path),
    ];
    return item;
  }

  Future<File> _nextAvailableFile(
    String folderPath,
    String base,
    String extension,
  ) async {
    var index = 0;
    while (true) {
      final suffix = index == 0 ? '' : '_$index';
      final file = File(p.join(folderPath, '$base$suffix$extension'));
      if (!await file.exists()) {
        return file;
      }
      index++;
    }
  }

  static const Set<String> _supportedExtensions = <String>{
    '.mp4',
    '.mov',
    '.mkv',
    '.webm',
    '.avi',
    '.mp3',
    '.wav',
    '.aac',
    '.m4a',
    '.ogg',
    '.flac',
  };
}
