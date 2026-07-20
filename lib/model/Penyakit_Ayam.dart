import 'package:smart_farming_app/model/gejala_model.dart';

class PenyakitGejala {
  final String id;
  final String penyakitId;
  final String gejalaId;
  final GejalaModel? gejala;
  final double? cfWeight;

  PenyakitGejala({
    required this.id,
    required this.penyakitId,
    required this.gejalaId,
    this.gejala,
    this.cfWeight,
  });

  factory PenyakitGejala.fromJson(Map<String, dynamic> json) {
    return PenyakitGejala(
      id: json['id'] ?? '',
      penyakitId: json['penyakit_id'] ?? '',
      gejalaId: json['gejala_id'] ?? '',
      gejala:
          json['gejala'] != null ? GejalaModel.fromJson(json['gejala']) : null,
      cfWeight: json['cf_weight'] != null ? double.tryParse(json['cf_weight'].toString()) : null,
    );
  }
}

class PenyakitAyam {
  final String id;
  final String namaPenyakit;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<PenyakitGejala> penyakitGejala;
  final List<Map<String, dynamic>> penanganan;

  PenyakitAyam({
    required this.id,
    required this.namaPenyakit,
    this.createdAt,
    this.updatedAt,
    this.penyakitGejala = const [],
    this.penanganan = const [],
  });

  factory PenyakitAyam.fromJson(Map<String, dynamic> json) {
    return PenyakitAyam(
      id: json['id'] ?? '',
      namaPenyakit: json['nama_penyakit'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      penyakitGejala: json['penyakitGejala'] != null
          ? (json['penyakitGejala'] as List)
              .map((e) => PenyakitGejala.fromJson(e))
              .toList()
          : (json['gejala'] != null
              ? (json['gejala'] as List).map((e) {
                  return PenyakitGejala(
                    id: e['id'] ?? '',
                    penyakitId: json['id'] ?? '',
                    gejalaId: e['id'] ?? '',
                    gejala: GejalaModel(
                      id: e['id'] ?? '',
                      namaGejala: e['nama_gejala'] ?? '',
                      gambar: '',
                    ),
                    cfWeight: e['bobot'] != null
                        ? double.tryParse(e['bobot'].toString())
                        : null,
                  );
                }).toList()
              : []),
      penanganan: json['penanganan'] != null
          ? List<Map<String, dynamic>>.from((json['penanganan'] as List)
              .map((e) => Map<String, dynamic>.from(e)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_penyakit': namaPenyakit,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Helper: list nama gejala yang terkait (untuk pre-fill edit form)
  List<String> get namaGejalaList => penyakitGejala
      .where((pg) => pg.gejala != null)
      .map((pg) => pg.gejala!.namaGejala)
      .toList();

  /// Helper: list id gejala yang terkait
  List<String> get idGejalaList => penyakitGejala
      .where((pg) => pg.gejala != null)
      .map((pg) => pg.gejalaId)
      .toList();

  String get directGambarUrl => '';
}
