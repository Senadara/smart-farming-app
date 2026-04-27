// lib/utils/certainty_factor.dart
// Implementasi Certainty Factor untuk diagnosis penyakit ternak (ayam)

class HasilCF {
  final String namaPenyakit;
  final double cfScore;

  const HasilCF({required this.namaPenyakit, required this.cfScore});

  /// Persentase keyakinan, dibulatkan ke 2 desimal
  double get persentase => double.parse((cfScore * 100).toStringAsFixed(2));

  @override
  String toString() => '$namaPenyakit (${persentase.toStringAsFixed(1)}%)';
}

/// Satu aturan dalam knowledge base:
/// penyakit dengan map {namaGejala: bobot CF pakar}
class _Penyakit {
  final String nama;
  final Map<String, double> gejala;

  const _Penyakit({required this.nama, required this.gejala});
}

/// Knowledge base sesuai tabel pembobotan
final List<_Penyakit> _knowledgeBase = [
  _Penyakit(
    nama: 'Avian Influenza',
    gejala: {
      'Nafsu makan menurun': 0.5,
      'Ngorok': 0.6,
      'Produksi telur menurun': 0.6,
      'Batuk': 0.6,
      'Jengger membiru': 0.9,
      'Leleran hidung': 0.7,
    },
  ),
  _Penyakit(
    nama: 'Gumboro',
    gejala: {
      'Nafsu makan menurun': 0.5,
      'Depresi': 0.8,
      'Tampak sayu': 0.7,
    },
  ),
  _Penyakit(
    nama: 'Lymphoid Leukosis',
    gejala: {
      'Nafsu makan menurun': 0.5,
      'Tampak sayu': 0.6,
      'Jengger membiru': 0.7,
    },
  ),
  _Penyakit(
    nama: 'Tetelo',
    gejala: {
      'Nafsu makan menurun': 0.5,
      'Ngorok': 0.6,
      'Produksi telur menurun': 0.6,
      'Batuk': 0.6,
      'Tampak sayu': 0.7,
    },
  ),
  _Penyakit(
    nama: 'Avian Encephalomyelitis',
    gejala: {
      'Tremor': 0.9,
      'Produksi telur menurun': 0.6,
      'Tampak sayu': 0.6,
    },
  ),
  _Penyakit(
    nama: 'Infectious Bronchitis',
    gejala: {
      'Ngorok': 0.7,
      'Produksi telur menurun': 0.8,
      'Batuk': 0.7,
      'Leleran hidung': 0.6,
    },
  ),
  _Penyakit(
    nama: 'Chronic Respiratory Disease',
    gejala: {
      'Ngorok': 0.8,
      'Batuk': 0.7,
      'Leleran hidung': 0.7,
    },
  ),
  _Penyakit(
    nama: 'Egg Drop Syndrome',
    gejala: {
      'Produksi telur menurun': 0.9,
      'Tampak sayu': 0.5,
      'Jengger pucat': 0.7,
    },
  ),
  _Penyakit(
    nama: 'Infectious Laryngotracheitis',
    gejala: {
      'Produksi telur menurun': 0.6,
      'Tampak sayu': 0.6,
      'Leleran hidung': 0.7,
    },
  ),
];

/// Kombinasi dua nilai CF secara iteratif:
/// CF_combined = CF_old + CF_new * (1 - CF_old)
double _kombinasiCF(double cfLama, double cfBaru) {
  return cfLama + cfBaru * (1 - cfLama);
}

/// Hitung CF untuk setiap penyakit berdasarkan gejala yang dipilih user.
///
/// [selectedGejala] — Set label gejala yang dipilih (harus sama persis
///                    dengan kunci pada knowledge base, case-sensitive).
///
/// Mengembalikan list [HasilCF] diurutkan dari skor CF tertinggi ke terendah.
/// Hanya penyakit yang memiliki minimal 1 gejala cocok yang diikutsertakan.
List<HasilCF> hitungCF(Set<String> selectedGejala) {
  final List<HasilCF> hasil = [];

  for (final penyakit in _knowledgeBase) {
    double cf = 0.0;
    bool adaGejala = false;

    for (final entry in penyakit.gejala.entries) {
      if (selectedGejala.contains(entry.key)) {
        adaGejala = true;
        cf = _kombinasiCF(cf, entry.value);
      }
    }

    if (adaGejala) {
      hasil.add(HasilCF(namaPenyakit: penyakit.nama, cfScore: cf));
    }
  }

  // Urutkan dari CF tertinggi
  hasil.sort((a, b) => b.cfScore.compareTo(a.cfScore));
  return hasil;
}
