import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool hardwareAcceleration = true;
  bool highQualityAudio = true;
  bool autoSaveRecordings = true;
  double videoBitrate = 25;
  double audioBitrate = 320;
  int videoFormat = 0;
  int audioFormat = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.chevron_left_rounded, size: 34),
              const SizedBox(width: 8),
              const Text(
                'Extraction Quality',
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(onPressed: null, child: const Text('Skip')),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'VIDEO SETTINGS',
            style: TextStyle(
              color: Color(0xFF2AA9FF),
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Resolution', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1529),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF274A87)),
                  ),
                  child: const Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '1080p Full HD (1920 × 1080)',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      Icon(Icons.open_with_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    const Text(
                      'Bitrate (Mbps)',
                      style: TextStyle(fontSize: 22),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16387A),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${videoBitrate.round()} Mbps',
                        style: const TextStyle(
                          color: Color(0xFF2AA9FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: videoBitrate,
                  min: 1,
                  max: 100,
                  onChanged: (double value) =>
                      setState(() => videoBitrate = value),
                ),
                const Row(
                  children: <Widget>[
                    Text('1 Mbps', style: TextStyle(color: Color(0xFF8FA4C3))),
                    Spacer(),
                    Text(
                      '100 Mbps',
                      style: TextStyle(color: Color(0xFF8FA4C3)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Format', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 10),
                _Segment(
                  labels: <String>['MP4', 'MKV', 'MOV'],
                  selectedIndex: videoFormat,
                  onChanged: (int value) => setState(() => videoFormat = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'AUDIO SETTINGS',
            style: TextStyle(
              color: Color(0xFF2AA9FF),
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Sample Rate', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _ChoiceButton(
                        title: '44.1 kHz',
                        selected: true,
                        onTap: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ChoiceButton(
                        title: '48 kHz',
                        selected: false,
                        onTap: null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    const Text(
                      'Bitrate (kbps)',
                      style: TextStyle(fontSize: 22),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16387A),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${audioBitrate.round()} kbps',
                        style: const TextStyle(
                          color: Color(0xFF2AA9FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: audioBitrate,
                  min: 64,
                  max: 512,
                  onChanged: (double value) =>
                      setState(() => audioBitrate = value),
                ),
                const Row(
                  children: <Widget>[
                    Text('64 kbps', style: TextStyle(color: Color(0xFF8FA4C3))),
                    Spacer(),
                    Text(
                      '512 kbps',
                      style: TextStyle(color: Color(0xFF8FA4C3)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Export Format', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 10),
                _Segment(
                  labels: <String>['MP3', 'WAV', 'AAC'],
                  selectedIndex: audioFormat,
                  onChanged: (int value) => setState(() => audioFormat = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: SwitchListTile.adaptive(
              title: const Text(
                'Hardware Acceleration',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Faster encoding using GPU cores',
                style: TextStyle(color: Color(0xFF8EA2C0)),
              ),
              value: hardwareAcceleration,
              onChanged: (bool value) =>
                  setState(() => hardwareAcceleration = value),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            child: SwitchListTile.adaptive(
              title: const Text(
                'High Quality Audio',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Use best bitrate profile when exporting',
                style: TextStyle(color: Color(0xFF8EA2C0)),
              ),
              value: highQualityAudio,
              onChanged: (bool value) =>
                  setState(() => highQualityAudio = value),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            child: SwitchListTile.adaptive(
              title: const Text(
                'Auto Save Recordings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Move captures to library automatically',
                style: TextStyle(color: Color(0xFF8EA2C0)),
              ),
              value: autoSaveRecordings,
              onChanged: (bool value) =>
                  setState(() => autoSaveRecordings = value),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Changes applied')));
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Apply Changes',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12213A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? const Color(0xFF165AF0) : const Color(0xFF0A1529),
          border: Border.all(color: const Color(0xFF274A87)),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1529),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List<Widget>.generate(
          labels.length,
          (int i) => Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: i == selectedIndex
                      ? const Color(0xFF185DF4)
                      : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: i == selectedIndex
                          ? Colors.white
                          : const Color(0xFF98AACE),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
