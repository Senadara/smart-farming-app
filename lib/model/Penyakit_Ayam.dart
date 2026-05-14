class PenyakitAyam {
  final String id;
  final String namaPenyakit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PenyakitAyam({
    required this.id,
    required this.namaPenyakit,
    this.createdAt,
    this.updatedAt,
  });

  factory PenyakitAyam.fromJson(Map<String, dynamic> json) {
    return PenyakitAyam(
      id: json['id'] ?? '',
      namaPenyakit: json['nama_penyakit'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
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

}