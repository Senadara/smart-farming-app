import 'package:flutter/material.dart';
import 'package:smart_farming_app/model/ayam.dart';

class PetakKandangMiniMapWidget extends StatefulWidget {
  const PetakKandangMiniMapWidget({
    super.key,
    required this.scrollController,
    required this.ayamLayout,
    required this.selectedAyam,
  });

  final ScrollController scrollController;
  final List<List<Ayam>> ayamLayout;
  final List<Ayam> selectedAyam;

  @override
  State<PetakKandangMiniMapWidget> createState() =>
      _PetakKandangMiniMapWidgetState();
}

class _PetakKandangMiniMapWidgetState extends State<PetakKandangMiniMapWidget> {
  final spacing = 1.0;
  final ayamSize = 10.0;

  int get totalRow => widget.ayamLayout.length;
  final scrollOffsetNotifier = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  double get miniMapWidth {
    double width = 0;
    final firstRow = widget.ayamLayout.first;
    for (final block in firstRow) {
      final kandang = block.ayamIds;
      final effectiveLength = kandang.isEmpty ? 1 : kandang.length;
      width += effectiveLength * ayamSize;
      width += (effectiveLength - 1) * spacing;
      width += spacing;
    }
    return width;
  }

  double get miniMapHeight {
    return totalRow * ayamSize + (totalRow - 1) * spacing;
  }

  double get indicatorHeight {
    if (!widget.scrollController.hasClients) return 0;
    final position = widget.scrollController.position;
    if (!position.hasViewportDimension) return 0;
    final viewport = position.viewportDimension;
    final maxScroll = position.maxScrollExtent;

    final contentHeight = maxScroll + viewport;
    final miniHeight = miniMapHeight;

    return (viewport / contentHeight) * miniHeight;
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final position = widget.scrollController.position;

    final offset = position.pixels;
    final viewport = position.viewportDimension;
    final maxScroll = position.maxScrollExtent;

    final contentHeight = maxScroll + viewport;
    final miniHeight = miniMapHeight;

    final startRatio = offset / contentHeight;

    scrollOffsetNotifier.value = startRatio * miniHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(), color: Colors.white),
      padding: const EdgeInsets.all(8),
      child: Stack(children: [_buildMiniMap(), _buildIndicator()]),
    );
  }

  Widget _buildMiniMap() {
    return Column(
      spacing: spacing,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(totalRow, (row) {
        final blockRow = widget.ayamLayout[row];
        return Row(
          spacing: spacing,
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(blockRow.length, (col) {
            final block = blockRow[col];
            final status = block.status;
            final ayam = block.ayamIds;

            final int effectiveLength = ayam.isEmpty ? 1 : ayam.length;
            final width = (effectiveLength * ayamSize) +
                ((effectiveLength - 1) * spacing);
            final height = ayamSize;

            if (status == LivestockStatus.ALLEY) {
              return SizedBox(width: width, height: height);
            }

            final isSelected = widget.selectedAyam.contains(block);

            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue
                    : status == LivestockStatus.AVAILABLE
                        ? Colors.green
                        : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildIndicator() {
    return ValueListenableBuilder<double>(
      valueListenable: scrollOffsetNotifier,
      builder: (context, top, child) {
        if (!widget.scrollController.hasClients) return const SizedBox();
        return Positioned(
          top: top,
          left: 0,
          right: 0,
          child: Container(
            height: indicatorHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
              color: Colors.red.withValues(alpha: 0.15),
            ),
          ),
        );
      },
    );
  }
}
