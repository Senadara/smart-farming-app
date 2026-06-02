import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

class UpdateStatusScreen extends StatefulWidget {
  final String id;
  const UpdateStatusScreen({super.key, required this.id});

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  final LaporanService _laporanService = LaporanService();
  Map<String, dynamic>? _laporan;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    // fetch data menggunakan service
    final result = await _laporanService.getLaporanAyamSakitById(widget.id);
    if (result['status'] == true) {
      setState(() {
        _laporan = result['data'];
        // pre-select status dari data yang sudah ada
        final existing =
            (_laporan?['laporan']?['Sakit']?['status'] ?? '') as String;
        if (existing == 'Sudah ditangani') {
          _selectedStatus = 'Sudah ditangani';
        } else if (existing == 'Belum ditangani') {
          _selectedStatus = 'Belum ditangani';
        } else {
          _selectedStatus = 'Belum ditangani';
        }
        _isLoading = false;
      });
    } else {
      debugPrint(result['message']);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih status penanganan terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ambil id dari relasi Sakit (bukan id laporan)
    final idLaporanSakit =
        _laporan?['laporan']?['Sakit']?['id'] as String? ?? widget.id;

    setState(() => _isSubmitting = true);

    final result = await _laporanService.updateLaporanSakit(
      idLaporanSakit,
      {'status': _selectedStatus},
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status berhasil diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // kembalikan true agar list bisa refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Gagal memperbarui status: ${result['message']?.toString() ?? 'Unknown error'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final laporan = _laporan!['laporan'] as Map<String, dynamic>;
    final namaPenyakit = _laporan!['namaPenyakit'] as Map<String, dynamic>?;
    final listGejala = (_laporan!['listGejala'] as List?) ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 80,
          title: const Header(
            headerType: HeaderType.back,
            title: 'Update Status Ayam Sakit',
            greeting: 'Update status laporan',
          ),
        ),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLaporanCard(laporan, namaPenyakit),
                  const SizedBox(height: 14),
                  _buildStatusSection(),
                  const SizedBox(height: 14),
                  _buildGejalaSection(listGejala),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      )),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: CustomButton(
            key: const Key('kirim_laporan_ternak'),
            onPressed: _isSubmitting ? null : _submitForm,
            buttonText: _isSubmitting ? 'Mengirim...' : 'Update Status',
            backgroundColor: green1,
            textStyle: semibold16.copyWith(color: white),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      return DateFormat('dd MMM yyyy', 'id').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  Widget _buildLaporanCard(
    Map<String, dynamic> laporan,
    Map<String, dynamic>? namaPenyakit,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: SizedBox(
              width: 90,
              height: 90,
              child: ImageBuilder(
                url: laporan['gambar'] ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          laporan['judul'] ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A2A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(laporan['createdAt']),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black45),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.coronavirus_outlined,
                          size: 13, color: Colors.black38),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          namaPenyakit?['nama_penyakit'] ??
                              'Diagnosis belum tersedia',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    laporan['catatan'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STATUS PENANGANAN',
          style: TextStyle(
            fontSize: 11,
            color: Colors.black38,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih status penanganan saat ini untuk laporan ini.',
                style:
                    TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 12),
              _StatusPill(
                label: 'Belum ditangani',
                subtitle: 'Ayam belum mendapat penanganan',
                badge: 'Perlu tindakan',
                badgeBg: const Color(0xFFFCEBEB),
                badgeText: const Color(0xFF791F1F),
                badgeIcon: Icons.warning_amber_rounded,
                activeColor: const Color(0xFFE24B4A),
                activeBg: const Color(0xFFFCEBEB),
                isSelected: _selectedStatus == 'Belum ditangani',
                onTap: () =>
                    setState(() => _selectedStatus = 'Belum ditangani'),
              ),
              const SizedBox(height: 8),
              _StatusPill(
                label: 'Sudah ditangani',
                subtitle: 'Ayam telah mendapat penanganan',
                badge: 'Selesai',
                badgeBg: const Color(0xFFEAF3DE),
                badgeText: const Color(0xFF27500A),
                badgeIcon: Icons.check_circle_outline_rounded,
                activeColor: const Color(0xFF3A5A3A),
                activeBg: const Color(0xFFEAF3DE),
                isSelected: _selectedStatus == 'Sudah ditangani',
                onTap: () =>
                    setState(() => _selectedStatus = 'Sudah ditangani'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGejalaSection(List listGejala) {
    if (listGejala.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GEJALA TERDETEKSI',
          style: TextStyle(
            fontSize: 11,
            color: Colors.black38,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listGejala.length,
            separatorBuilder: (_, __) => Divider(
              height: 0,
              thickness: 0.5,
              color: Colors.grey[200],
            ),
            itemBuilder: (_, i) {
              final g = listGejala[i] as Map<String, dynamic>;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: ImageBuilder(
                          url: g['gambar'] ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        g['nama_gejala'] ?? '-',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF1A2A1A)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final String subtitle;
  final String badge;
  final Color badgeBg;
  final Color badgeText;
  final IconData badgeIcon;
  final Color activeColor;
  final Color activeBg;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusPill({
    required this.label,
    required this.subtitle,
    required this.badge,
    required this.badgeBg,
    required this.badgeText,
    required this.badgeIcon,
    required this.activeColor,
    required this.activeBg,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? activeColor.withOpacity(0.4) : Colors.grey[300]!,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? activeColor : Colors.white,
                border: Border.all(
                  color: isSelected ? activeColor : Colors.grey[350]!,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? activeColor : const Color(0xFF1A2A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon, size: 10, color: badgeText),
                  const SizedBox(width: 3),
                  Text(
                    badge,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: badgeText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
