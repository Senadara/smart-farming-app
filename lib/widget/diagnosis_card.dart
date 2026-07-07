import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class DiagnosisCard extends StatelessWidget {
  final String namaPenyakit;
  final List<dynamic> gejala;
  final double? cfScore;
  final List<String> selectedAyamIds;

  const DiagnosisCard({
    super.key,
    required this.namaPenyakit,
    required this.gejala,
    this.cfScore,
    this.selectedAyamIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: green4,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: green1.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header kartu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: green1.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.medical_information_outlined, color: green1, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Hasil Diagnosis Penyakit',
                  style: semibold16.copyWith(color: green1),
                ),
                const Spacer(),
                // Badge status terdeteksi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 12, color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Terdeteksi',
                        style: regular14.copyWith(
                            color: Colors.orange.shade700, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Konten utama
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama penyakit
                Text(
                  namaPenyakit,
                  style: semibold20.copyWith(color: dark1, fontSize: 22),
                ),
                const SizedBox(height: 10),

                // Ayam yang dipilih
                if (selectedAyamIds.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.pets_outlined, size: 14, color: green1),
                      const SizedBox(width: 6),
                      Text(
                        'Petak Dilaporkan (${selectedAyamIds.length} petak)',
                        style: semibold14.copyWith(color: green1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: selectedAyamIds
                        .map(
                          (label) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: green1.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: green1.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle,
                                    size: 7, color: green1),
                                const SizedBox(width: 5),
                                Text(
                                  label,
                                  style: regular14.copyWith(
                                      color: green1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 2),
                
                if (cfScore != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Tingkat keyakinan', style: regular14.copyWith(color: green1, fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: cfScore!,
                            backgroundColor: const Color(0xFFC0DD97),
                            valueColor: AlwaysStoppedAnimation<Color>(green1),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(cfScore! * 100).toStringAsFixed(1)}%',
                        style: semibold12.copyWith(color: green1),
                      ),
                    ],
                  ),
                ],

                // Gejala
                if (gejala.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.list_alt_outlined, size: 16, color: dark1),
                      const SizedBox(width: 6),
                      Text('Gejala yang Ditemukan', style: semibold16.copyWith(color: dark1)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...gejala.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: green1,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.toString(),
                              style: regular14.copyWith(color: dark1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else
                  Text(
                    'Tidak ada gejala yang tercatat.',
                    style: regular14.copyWith(color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}