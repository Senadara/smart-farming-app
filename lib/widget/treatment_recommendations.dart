import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class PenangananPenyakit {
  final String namaPenanganan;
  final String deskripsiPenanganan;
  final String? gambar;
  bool isExpanded;

  PenangananPenyakit({
    required this.namaPenanganan,
    required this.deskripsiPenanganan,
    this.gambar,
    this.isExpanded = false,
  });
}

class TreatmentRecommendations extends StatefulWidget {
  final List<dynamic>? customPenanganan;
  final String? title;
  final String? subtitle;
  final bool showDisclaimer;

  const TreatmentRecommendations({
    super.key,
    this.customPenanganan,
    this.title,
    this.subtitle,
    this.showDisclaimer = true,
  });

  @override
  State<TreatmentRecommendations> createState() =>
      _TreatmentRecommendationsState();
}

class _TreatmentRecommendationsState extends State<TreatmentRecommendations> {
  late final List<PenangananPenyakit> _penangananList;

  @override
  void initState() {
    super.initState();
    final rawList = widget.customPenanganan ?? _dummyPenanganan();
    _penangananList = rawList.asMap().entries.map((entry) {
      final index = entry.key;
      final e = entry.value;
      return PenangananPenyakit(
        namaPenanganan: e['nama'] as String? ??
            (e['namaPenanganan'] as String? ?? 'Langkah Penanganan ${index + 1}'),
        deskripsiPenanganan: e['deskripsi'] as String? ??
            (e['deskripsiPenanganan'] as String? ?? (e['penanganan'] as String? ?? '')),
        gambar: e['gambar'] as String?,
      );
    }).toList();
  }

  List<Map<String, String>> _dummyPenanganan() => [
        {
          'nama': 'Isolasi ternak yang terinfeksi',
          'deskripsi':
              'Pisahkan ayam yang menunjukkan gejala ke kandang terpisah segera. '
                  'Hindari kontak dengan unggas sehat. Gunakan alat pelindung diri '
                  'saat menangani ternak yang terinfeksi.'
        },
        {
          'nama': 'Hubungi dokter hewan setempat',
          'deskripsi':
              'Laporkan kejadian kepada dokter hewan atau dinas peternakan '
                  'setempat untuk mendapat penanganan profesional dan mencegah '
                  'penyebaran lebih lanjut.'
        },
        {
          'nama': 'Desinfeksi kandang dan peralatan',
          'deskripsi':
              'Bersihkan dan semprot seluruh kandang dengan disinfektan. '
                  'Cuci semua peralatan kandang secara menyeluruh. Lakukan '
                  'biosekuriti ketat untuk mencegah penularan.'
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section rekomendasi penanganan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medical_services_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title ?? 'Rekomendasi Penanganan',
                      style: semibold16.copyWith(color: dark1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      '${_penangananList.length} langkah',
                      style: regular14.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Accordion penanganan
              ..._penangananList.asMap().entries.map(
                    (entry) => _PenangananTile(
                      index: entry.key,
                      item: entry.value,
                      onToggle: () => setState(
                        () => entry.value.isExpanded = !entry.value.isExpanded,
                      ),
                    ),
                  ),
            ],
          ),
        ),

        if (widget.showDisclaimer) ...[  
          const SizedBox(height: 12),
          // Disclaimer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Diagnosis ini bersifat pendukung. Selalu konsultasikan '
                      'dengan dokter hewan untuk penanganan lebih lanjut.',
                      style: regular14.copyWith(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PenangananTile extends StatelessWidget {
  final int index;
  final PenangananPenyakit item;
  final VoidCallback onToggle;

  const _PenangananTile({
    required this.index,
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isExpanded
                ? green1.withOpacity(0.4)
                : Colors.grey.shade200,
            width: item.isExpanded ? 1.2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                // Header accordion
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      // Nomor urut
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: item.isExpanded
                              ? green1.withOpacity(0.12)
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: item.isExpanded
                                ? green1.withOpacity(0.4)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: semibold12.copyWith(
                              color: item.isExpanded
                                  ? green1
                                  : Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Judul penanganan
                      Expanded(
                        child: Text(
                          item.namaPenanganan,
                          style: semibold14.copyWith(
                            color: item.isExpanded ? green1 : dark1,
                          ),
                        ),
                      ),

                      // Chevron animasi
                      AnimatedRotation(
                        turns: item.isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color:
                              item.isExpanded ? green1 : Colors.grey.shade400,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                // Body accordion
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: item.isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: Colors.grey.shade100, height: 1),
                        const SizedBox(height: 12),
                        Text(
                          item.deskripsiPenanganan,
                          style: regular14.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                        if (item.gambar != null && item.gambar!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.gambar!,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return const SizedBox(
                                  height: 120,
                                  child: Center(
                                      child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              },
                              errorBuilder: (ctx, err, st) => Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        color: Colors.grey)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
