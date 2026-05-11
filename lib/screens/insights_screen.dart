import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/media_library_service.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<MediaItem>>(
        valueListenable: MediaLibraryService.instance.items,
        builder: (BuildContext context, List<MediaItem> items, _) {
          final library = MediaLibraryService.instance;
          final totalSize = library.totalSizeInBytes;
          final totalFiles = items.length;
          final audioFiles = library.audioCount;
          final videoFiles = library.videoCount;
          final newest = library.newestItem;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const Text(
                'Performance Analytics',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'LIVE LIBRARY DATA',
                style: TextStyle(color: Color(0xFF2AA9FF), letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF101D34),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Current Library Load',
                      style: TextStyle(color: Color(0xFFA0B3CF)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Text(
                          _formatBytes(totalSize),
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'used',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$totalFiles files',
                          style: const TextStyle(
                            color: Color(0xFF24E97E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _UsageChart(audioCount: audioFiles, videoCount: videoFiles),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCard(
                      title: 'AUDIO',
                      value: '$audioFiles',
                      status: 'Ready to play',
                      statusColor: const Color(0xFF21E98B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'VIDEO',
                      value: '$videoFiles',
                      status: 'Ready to preview',
                      statusColor: const Color(0xFF2AA9FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF101D34),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Storage Efficiency',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _StorageCompare(
                      audioBytes: totalFiles == 0
                          ? 0
                          : totalSize * audioFiles ~/ totalFiles,
                      videoBytes: totalFiles == 0
                          ? 0
                          : totalSize * videoFiles ~/ totalFiles,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'NEWEST ITEM',
                value: newest?.name ?? 'None yet',
                status: newest == null
                    ? 'Import or record media to begin'
                    : _formatDate(newest.createdAt),
                statusColor: const Color(0xFF8EA2C0),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.assessment_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Export Summary', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.status,
    required this.statusColor,
  });

  final String title;
  final String value;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101D34),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              letterSpacing: 1.2,
              color: Color(0xFF8EA2C0),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _UsageChart extends StatelessWidget {
  const _UsageChart({required this.audioCount, required this.videoCount});

  final int audioCount;
  final int videoCount;

  @override
  Widget build(BuildContext context) {
    final total = (audioCount + videoCount).clamp(1, 1 << 30);
    return SizedBox(
      height: 150,
      child: CustomPaint(
        painter: _ChartPainter(
          audioRatio: audioCount / total,
          videoRatio: videoCount / total,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.audioRatio, required this.videoRatio});

  final double audioRatio;
  final double videoRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final videoPaint = Paint()
      ..color = const Color(0xFF2AA9FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final audioPaint = Paint()
      ..color = const Color(0xFF24E97E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final videoPath = Path()
      ..moveTo(0, size.height * 0.72)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.58,
        size.width * 0.35,
        size.height * (1.0 - videoRatio),
        size.width * 0.55,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.7,
        size.height * 0.24,
        size.width * 0.84,
        size.height * 0.55,
        size.width,
        size.height * 0.33,
      );

    final audioPath = Path()
      ..moveTo(0, size.height * 0.52)
      ..cubicTo(
        size.width * 0.15,
        size.height * 0.34,
        size.width * 0.3,
        size.height * (1.0 - audioRatio),
        size.width * 0.5,
        size.height * 0.52,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.62,
        size.width * 0.82,
        size.height * 0.24,
        size.width,
        size.height * 0.46,
      );

    canvas.drawPath(videoPath, videoPaint);
    canvas.drawPath(audioPath, audioPaint);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.audioRatio != audioRatio ||
        oldDelegate.videoRatio != videoRatio;
  }
}

class _StorageCompare extends StatelessWidget {
  const _StorageCompare({required this.audioBytes, required this.videoBytes});

  final int audioBytes;
  final int videoBytes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF596A86),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF31415E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Audio ${_formatBytes(audioBytes)}',
                style: const TextStyle(color: Color(0xFF8EA2C0)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF2AA9FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 72,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C7DD2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Video ${_formatBytes(videoBytes)}',
                style: const TextStyle(color: Color(0xFF8EA2C0)),
              ),
            ],
          ),
        ),
      ],
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

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}
