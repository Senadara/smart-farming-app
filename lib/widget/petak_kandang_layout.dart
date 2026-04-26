import 'package:flutter/material.dart';
import 'package:smart_farming_app/model/ayam.dart';

class PetakKandangLayout extends StatefulWidget {
  const PetakKandangLayout({
    super.key,
    this.scrollController,
    required this.ayamLayout,
    this.selectedAyam = const [],
    this.onScrolling,
    this.onAyamSelected,
  });

  final ScrollController? scrollController;
  final List<List<Ayam>> ayamLayout;
  final List<Ayam> selectedAyam;
  final void Function(bool scrolling)? onScrolling;
  final void Function(Ayam ayam)? onAyamSelected;

  @override
  State<PetakKandangLayout> createState() => _PetakKandangLayoutState();
}

class _PetakKandangLayoutState extends State<PetakKandangLayout> {
  final spacing = 4.0;
  final ayamSize = 45.0;

  int get totalRow => widget.ayamLayout.length;

  late ScrollController scrollController;
  bool _ownedController = false;

  @override
  void initState() {
    if (widget.scrollController != null) {
      scrollController = widget.scrollController!;
    } else {
      scrollController = ScrollController();
      _ownedController = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_ownedController) {
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          widget.onScrolling?.call(true);
        } else if (notification is ScrollEndNotification) {
          widget.onScrolling?.call(false);
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: spacing,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(totalRow, (row) {
            final blockRow = widget.ayamLayout[row];
            return Row(
              spacing: spacing,
              mainAxisAlignment: MainAxisAlignment.center,
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

                return GestureDetector(
                  onTap: () {
                    widget.onAyamSelected?.call(block);
                  },
                  child: Container(
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
                    alignment: Alignment.center,
                    child: Text(
                      block.displayLabel ?? ayam.join(" | "),
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      style: Theme.of(
                        context,
                      )
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.white, fontSize: 8),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
