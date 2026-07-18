import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_farming_app/model/ayam.dart';
import 'package:smart_farming_app/widget/petak_kandang_layout.dart';
import 'package:smart_farming_app/widget/petak_kandang_mini_map_widget.dart';

class KandangLayoutWidget extends StatefulWidget {
  const KandangLayoutWidget({
    super.key,
    required this.ayamLayout,
    this.onSelectionChanged,
  });

  final List<List<Ayam>> ayamLayout;
  final void Function(List<String> selectedIds, List<Ayam> selectedAyam)?
      onSelectionChanged;

  @override
  State<KandangLayoutWidget> createState() => KandangLayoutWidgetState();
}

class KandangLayoutWidgetState extends State<KandangLayoutWidget> {
  final _scrollController = ScrollController();
  final _selectedAyamNotifier = ValueNotifier<List<Ayam>>(const []);
  final _scrollNotifier = ValueNotifier<bool>(false);
  final Set<Ayam> _selected = {};

  Timer? _hideTimer;

  void selectAll() {
    setState(() {
      _selected.clear();
      for (final row in widget.ayamLayout) {
        for (final block in row) {
          final status = block.status;
          final sudahDitangani = status == LivestockStatus.SICK && block.sickStatus == 'Sudah ditangani';
          if (status == LivestockStatus.AVAILABLE || sudahDitangani) {
            _selected.add(block);
          }
        }
      }
      final selectedList = _selected.toList();
      _selectedAyamNotifier.value = selectedList;

      final selectedIds = selectedList.expand((a) => a.ayamIds).toList();
      widget.onSelectionChanged?.call(selectedIds, selectedList);
    });
  }

  void deselectAll() {
    setState(() {
      _selected.clear();
      _selectedAyamNotifier.value = const [];
      widget.onSelectionChanged?.call(const [], const []);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _selectedAyamNotifier.dispose();
    _scrollNotifier.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onScroll(bool scrolling) {
    _hideTimer?.cancel();

    if (scrolling) {
      _scrollNotifier.value = true;
      return;
    }

    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) _scrollNotifier.value = false;
    });
  }

  void _onAyamClicked(Ayam ayam) {
    if (!_selected.remove(ayam)) {
      _selected.add(ayam);
    }

    final selectedList = _selected.toList();
    _selectedAyamNotifier.value = selectedList;

    final selectedIds = selectedList.expand((a) => a.ayamIds).toList();
    widget.onSelectionChanged?.call(selectedIds, selectedList);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Ayam>>(
      valueListenable: _selectedAyamNotifier,
      builder: (context, selectedAyam, _) {
        return Stack(
          children: [
            PetakKandangLayout(
              scrollController: _scrollController,
              ayamLayout: widget.ayamLayout,
              selectedAyam: selectedAyam,
              onScrolling: _onScroll,
              onAyamSelected: _onAyamClicked,
            ),
            Positioned(
              left: 16,
              child: ValueListenableBuilder<bool>(
                valueListenable: _scrollNotifier,
                builder: (context, isScrolling, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: isScrolling ? child : const SizedBox(),
                  );
                },
                child: PetakKandangMiniMapWidget(
                  scrollController: _scrollController,
                  ayamLayout: widget.ayamLayout,
                  selectedAyam: selectedAyam,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}