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
  final void Function(List<String> selectedIds, List<Ayam> selectedAyam)? onSelectionChanged;

  @override
  State<KandangLayoutWidget> createState() => _KandangLayoutWidgetState();
}

class _KandangLayoutWidgetState extends State<KandangLayoutWidget> {
  final scrollController = ScrollController();
  final selectedAyamNotifier = ValueNotifier<List<Ayam>>([]);

  Timer? hideTimer;
  final scrollNotifier = ValueNotifier(false);

  @override
  void dispose() {
    scrollController.dispose();
    selectedAyamNotifier.dispose();
    scrollNotifier.dispose();
    super.dispose();
  }

  void onScroll(bool scrolling) async {
    hideTimer?.cancel();

    if (scrolling) {
      scrollNotifier.value = scrolling;
    } else {
      hideTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        scrollNotifier.value = false;
      });
    }
  }

  void onAyamClicked(Ayam ayam) {
    final isSelected = selectedAyamNotifier.value.contains(ayam);
    final latesSelected = List.of(selectedAyamNotifier.value);
    if (isSelected) {
      latesSelected.remove(ayam);
    } else {
      latesSelected.add(ayam);
    }
    selectedAyamNotifier.value = latesSelected;

    final selectedIds =
        selectedAyamNotifier.value.expand((ayam) => ayam.ayamIds).toList();
    print('Kotak terpilih: $selectedIds');
    widget.onSelectionChanged?.call(selectedIds, List.of(selectedAyamNotifier.value));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedAyamNotifier,
      builder: (context, selectedAyam, _) {
        return Stack(
          children: [
            PetakKandangLayout(
              scrollController: scrollController,
              ayamLayout: widget.ayamLayout,
              selectedAyam: selectedAyam,
              onScrolling: onScroll,
              onAyamSelected: onAyamClicked,
            ),
            Positioned(
              left: 16,
              child: ValueListenableBuilder(
                valueListenable: scrollNotifier,
                builder: (context, isScrolling, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: isScrolling ? child : const SizedBox(),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  );
                },
                child: PetakKandangMiniMapWidget(
                  scrollController: scrollController,
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
