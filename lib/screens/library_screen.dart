import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/media_item.dart';
import '../services/media_library_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.onOpenPlayer});

  final ValueChanged<MediaItem> onOpenPlayer;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _importing = false;
  int _filter = 0;

  Future<void> _importMedia() async {
    setState(() => _importing = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const <String>[
          'mp4',
          'mov',
          'mkv',
          'webm',
          'avi',
          'mp3',
          'wav',
          'aac',
          'm4a',
          'ogg',
          'flac',
        ],
      );

      final path = picked?.files.single.path;
      if (path != null) {
        await MediaLibraryService.instance.addFile(File(path));
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media imported successfully')),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Library',
                    style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: null,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF151E2D),
                  ),
                  icon: const Icon(Icons.tune_rounded),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _importing ? null : _importMedia,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF2E50FF),
                  ),
                  icon: _importing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search recordings...',
                hintStyle: const TextStyle(color: Color(0xFF7184A2)),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: const Color(0xFF111923),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF151E2D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(child: _tabChip('All', 0)),
                  Expanded(child: _tabChip('Video', 1)),
                  Expanded(child: _tabChip('Audio', 2)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder<List<MediaItem>>(
                valueListenable: MediaLibraryService.instance.items,
                builder: (BuildContext context, List<MediaItem> items, _) {
                  final filtered = items.where((MediaItem item) {
                    if (_filter == 1) {
                      return item.mediaType == MediaType.video;
                    }
                    if (_filter == 2) {
                      return item.mediaType == MediaType.audio;
                    }
                    return true;
                  }).toList();

                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No files found. Add media or record from Record tab.',
                      ),
                    );
                  }

                  return GridView.builder(
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.82,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (BuildContext context, int index) {
                      final item = filtered[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => widget.onOpenPlayer(item),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: AppTheme.panel,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: const LinearGradient(
                                        colors: <Color>[
                                          Color(0xFF192B43),
                                          Color(0xFF0D1522),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        item.mediaType == MediaType.video
                                            ? Icons.movie_creation_rounded
                                            : Icons.multitrack_audio,
                                        color: AppTheme.accentSoft,
                                        size: 44,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.readableSize,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _dateLabel(item.createdAt),
                                  style: const TextStyle(
                                    color: Color(0xFF7E93B4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabChip(String title, int value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? Colors.black : Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFFA0B3D0),
          ),
        ),
      ),
    );
  }
}

String _dateLabel(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m';
}
