class GejalaModel {
  final String id;
  final String namaGejala;
  final String gambar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GejalaModel({
    required this.id,
    required this.namaGejala,
    required this.gambar,
    this.createdAt,
    this.updatedAt,
  });

  factory GejalaModel.fromJson(Map<String, dynamic> json) {
    return GejalaModel(
      id: json['id'] ?? '',
      namaGejala: json['nama_gejala'] ?? '',
      gambar: json['gambar'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_gejala': namaGejala,
      'gambar': gambar,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to get direct image URL  
  String get directGambarUrl {
    if (gambar.isEmpty) return '';

    // Handle Imgur links that are not direct
    if (gambar.contains('imgur.com') && !gambar.contains('i.imgur.com')) {
      // Handle album links (remove /a/ and point to i.imgur.com)
      String cleanUrl = gambar.replaceAll('imgur.com/a/', 'i.imgur.com/');
      // Handle page links (point to i.imgur.com)
      cleanUrl = cleanUrl.replaceAll('imgur.com/', 'i.imgur.com/');

      // Add a common extension if missing (Imgur redirects correctly often, but .png is safest)
      if (!cleanUrl.contains('.png') &&
          !cleanUrl.contains('.jpg') &&
          !cleanUrl.contains('.jpeg')) {
        return '$cleanUrl.png';
      }
      return cleanUrl;
    }

    return gambar;
  }
}
