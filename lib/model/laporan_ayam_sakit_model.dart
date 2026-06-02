import 'package:flutter/material.dart';

class SakitDetail {
  final String id;
  final String diagnosisPenyakit;
  final String status;
  final DateTime createdAt;

  SakitDetail({
    required this.id,
    required this.diagnosisPenyakit,
    required this.status,
    required this.createdAt,
  });

  factory SakitDetail.fromJson(Map<String, dynamic> json) => SakitDetail(
        id: json['id'] ?? '',
        diagnosisPenyakit: json['diagnosisPenyakit'] ?? '',
        status: json['status'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class LaporanAyamSakit {
  final String id;
  final String judul;
  final String tipe;
  final String gambar;
  final String catatan;
  final DateTime createdAt;
  final SakitDetail sakit;

  LaporanAyamSakit({
    required this.id,
    required this.judul,
    required this.tipe,
    required this.gambar,
    required this.catatan,
    required this.createdAt,
    required this.sakit,
  });

  factory LaporanAyamSakit.fromJson(Map<String, dynamic> json) =>
      LaporanAyamSakit(
        id: json['id'] ?? '',
        judul: json['judul'] ?? '',
        tipe: json['tipe'] ?? '',
        gambar: json['gambar'] ?? '',
        catatan: json['catatan'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        sakit: SakitDetail.fromJson(json['Sakit']),
      );

  /// Maps status string → display label and color
  ({String label, Color bg, Color text}) get statusInfo {
    debugPrint(sakit.status);
    switch (sakit.status) {
      case 'Sudah ditangani':
        return (
          label: 'Sudah ditangani',
          bg: const Color(0xFFE6F4EA),
          text: const Color(0xFF2E7D32),
        );
      case 'Belum ditangani':
        return (
          label: 'Belum ditangani',
          bg: const Color(0xFFFFF3E0),
          text: const Color(0xFFE65100),
        );
      default:
        return (
          label: 'Belum ditangani',
          bg: const Color(0xFFFFEBEE),
          text: const Color(0xFFC62828),
        );
    }
  }
}
