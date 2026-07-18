import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_ayam_screem.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_ternak_screen.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/header.dart';

class PilihLayoutTernakScreen extends StatefulWidget {
  final String greeting;
  final String tipe;
  final int step;
  final Map<String, dynamic> data;

  const PilihLayoutTernakScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PilihLayoutTernakScreen> createState() => _PilihLayoutTernakScreenState();
}

class _PilihLayoutTernakScreenState extends State<PilihLayoutTernakScreen> {

  final List<Map<String, String>> _layouts = [
    {
      'value': 'list',
      'label': 'List',
      'subtitle': 'Tampilan daftar',
      'image': 'assets/images/Skeleton frame list kandang.png',
    },
    {
      'value': 'grid',
      'label': 'Grid',
      'subtitle': 'Tampilan kandang ayam',
      'image': 'assets/images/Skeleton frame grid kandang.png',
    },
  ];

  void _navigateTo(String value) {
    if (value == 'list') {
      context.push('/pilih-ternak',
        extra: PilihTernakScreen(
            greeting: widget.greeting,
            data: widget.data,
            tipe: widget.tipe,
            step: widget.step + 1));
    } else if (value == 'grid') {
      context.push('/pilih-ayam',
        extra: PilihAyamScreen(
            greeting: widget.greeting,
            data: widget.data,
            tipe: widget.tipe,
            step: widget.step + 1));
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: Header(
            headerType: HeaderType.back,
            title: 'Menu Pelaporan',
            greeting: widget.greeting,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          children: [
            BannerWidget(
              title: 'Step ${widget.step} - Pilih Layout',
              subtitle: 'Pilih layout kandang yang akan dilakukan pelaporan!',
              showDate: true,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Layout Kandang',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _layouts.map((layout) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: layout == _layouts.first ? 8 : 0,
                            left: layout == _layouts.last ? 8 : 0,
                          ),
                          child: _LayoutRadioCard(
                            label: layout['label']!,
                            subtitle: layout['subtitle']!,
                            imagePath: layout['image']!,
                            isSelected: false,
                            onTap: () => _navigateTo(layout['value']!),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}

class _LayoutRadioCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _LayoutRadioCard({
    required this.label,
    required this.subtitle,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8F5E9)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? green1
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio dot top-right
            Align(
              alignment: Alignment.topRight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? green1 : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? green1
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check,
                        size: 13, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            // Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.home_work_outlined,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? green1
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? green1.withOpacity(0.7)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}