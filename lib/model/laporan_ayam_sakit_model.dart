import 'package:flutter/material.dart';
import 'package:smart_farming_app/model/Ayam.dart';

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
  final List<dynamic> objekBudidayaList;

  LaporanAyamSakit({
    required this.id,
    required this.judul,
    required this.tipe,
    required this.gambar,
    required this.catatan,
    required this.createdAt,
    required this.sakit,
    required this.objekBudidayaList,
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
        objekBudidayaList: json['objekBudidayaList'] ?? [],
      );

  /// Label posisi kandang saja, mis. "B5, C5".
  /// Tidak lagi digabung dengan nama penyakit — nama penyakit
  /// sudah ditampilkan terpisah di baris diagnosis pada card.
  String get kandangLabel {
    if (objekBudidayaList.isEmpty) return judul;

    final labels = objekBudidayaList
        .map((item) => getAyamLabelFromNamaId(item['namaId']?.toString() ?? ''))
        .where((label) => label.isNotEmpty)
        .toList();

    return labels.isEmpty ? judul : labels.join(', ');
  }

  /// Jumlah ekor ayam yang dilaporkan sakit, untuk konteks tambahan di UI
  /// (mis. "2 ekor") tanpa perlu mengulang nama penyakit.
  int get jumlahTernak => objekBudidayaList.length;

  /// Maps status string → display label and color
  ({String label, Color bg, Color text, IconData icon}) get statusInfo {
    switch (sakit.status) {
      case 'Sudah ditangani':
      case 'Sembuh':
        return (
          label: 'Sembuh',
          bg: const Color(0xFFE6F4EA),
          text: const Color(0xFF2E7D32),
          icon: Icons.check_circle_outline,
        );
      case 'Pemantauan':
        return (
          label: 'Pemantauan',
          bg: const Color(0xFFFFF8E1),
          text: const Color(0xFFF57F17),
          icon: Icons.visibility_outlined,
        );
      case 'Belum ditangani':
      case 'Belum Ditangani':
        return (
          label: 'Belum Ditangani',
          bg: const Color(0xFFFFEBEE),
          text: const Color(0xFFC62828),
          icon: Icons.priority_high_rounded,
        );
      case 'Mati':
        return (
          label: 'Mati',
          bg: const Color(0xFFFFEBEE),
          text: const Color(0xFFC62828),
          icon: Icons.cancel_outlined,
        );
      default:
        return (
          label: 'Belum Ditangani',
          bg: const Color(0xFFFFEBEE),
          text: const Color(0xFFC62828),
          icon: Icons.priority_high_rounded,
        );
    }
  }
}