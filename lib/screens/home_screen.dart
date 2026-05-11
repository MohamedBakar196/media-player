import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/media_item.dart';
import '../services/media_library_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onOpenRecorder,
    required this.onOpenLibrary,
    required this.onOpenPlayer,
  });

  final VoidCallback onOpenRecorder;
  final VoidCallback onOpenLibrary;
  final ValueChanged<MediaItem> onOpenPlayer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<MediaItem>>(
        valueListenable: MediaLibraryService.instance.items,
        builder: (BuildContext context, List<MediaItem> items, _) {
          final storageUsed = items.fold<int>(
            0,
            (int total, MediaItem item) => total + item.sizeInBytes,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Row(
                children: <Widget>[
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFF204D88),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Welcome back,',
                          style: TextStyle(color: Color(0xFF91A5C4)),
                        ),
                        Text(
                          'Local Studio',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onOpenLibrary,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF101D34),
                    ),
                    icon: const Icon(Icons.video_library_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Start Recording',
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ActionCard(
                      title: 'Capture Video',
                      icon: Icons.videocam_rounded,
                      active: true,
                      onTap: onOpenRecorder,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      title: 'Open Library',
                      icon: Icons.video_library_rounded,
                      active: false,
                      onTap: onOpenLibrary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF101D34),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.cloud_outlined,
                          color: Color(0xFF3EBAFF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Storage: ${_formatBytes(storageUsed)} / 10 GB',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: (storageUsed / (10 * 1024 * 1024 * 1024)).clamp(
                          0.0,
                          1.0,
                        ),
                        minHeight: 8,
                        backgroundColor: const Color(0xFF283E60),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2AA9FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${items.length} files saved locally',
                        style: const TextStyle(color: Color(0xFF8EA2C0)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  const Text(
                    'Recent Files',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onOpenLibrary,
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (items.isEmpty)
                Container(
                  height: 140,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF101D34),
                  ),
                  child: const Text(
                    'No files yet. Start from Record or import from Library.',
                  ),
                )
              else
                Column(
                  children: items.take(3).map((MediaItem item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101D34),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: ListTile(
                        onTap: () => onOpenPlayer(item),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color(0xFF1E385E),
                                Color(0xFF0C162B),
                              ],
                            ),
                          ),
                          child: Icon(
                            item.mediaType == MediaType.video
                                ? Icons.play_circle_fill_rounded
                                : Icons.graphic_eq_rounded,
                            color: const Color(0xFF2AA9FF),
                          ),
                        ),
                        title: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${item.readableSize} • ${_dateLabel(item.createdAt)}',
                          style: const TextStyle(color: Color(0xFF8EA2C0)),
                        ),
                        trailing: const Icon(Icons.more_vert_rounded),
                      ),
                    );
                  }).toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

String _dateLabel(DateTime date) {
  final twoDigitDay = date.day.toString().padLeft(2, '0');
  final twoDigitMonth = date.month.toString().padLeft(2, '0');
  final twoDigitHour = date.hour.toString().padLeft(2, '0');
  final twoDigitMinute = date.minute.toString().padLeft(2, '0');
  return '$twoDigitDay/$twoDigitMonth $twoDigitHour:$twoDigitMinute';
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: active
                ? const <Color>[Color(0xFF34B4FF), Color(0xFF2F7CFF)]
                : const <Color>[Color(0xFF151F33), Color(0xFF0D1525)],
          ),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              size: 38,
              color: active ? Colors.black87 : AppTheme.accentSoft,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: active ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
