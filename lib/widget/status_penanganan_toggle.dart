import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

enum StatusPenanganan {
  belumDitangani('Belum Ditangani', 'Perlu tindakan segera'),
  sudahDitangani('Sudah Ditangani', 'Ternak telah ditangani');

  final String label;
  final String description;
  const StatusPenanganan(this.label, this.description);
}

class StatusPenangananToggle extends StatefulWidget {
  final StatusPenanganan initialValue;
  final ValueChanged<StatusPenanganan>? onChanged;

  const StatusPenangananToggle({
    super.key,
    this.initialValue = StatusPenanganan.belumDitangani,
    this.onChanged,
  });

  @override
  State<StatusPenangananToggle> createState() => _StatusPenangananToggleState();
}

class _StatusPenangananToggleState extends State<StatusPenangananToggle> {
  StatusPenanganan _selected = StatusPenanganan.belumDitangani;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  void _onSelect(StatusPenanganan status) {
    if (_selected == status) return; // Hindari rebuild tidak perlu
    setState(() => _selected = status);
    widget.onChanged?.call(status);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: StatusPenanganan.values
              .map((status) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right:
                            status == StatusPenanganan.belumDitangani ? 8 : 0,
                      ),
                      child: _StatusOption(
                        status: status,
                        isSelected: _selected == status,
                        onTap: () => _onSelect(status),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),
        _StatusBadge(status: _selected),
      ],
    );
  }
}

class _StatusOption extends StatelessWidget {
  final StatusPenanganan status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  bool get _isBelum => status == StatusPenanganan.belumDitangani;

  Color get _selectedBorderColor =>
      _isBelum ? const Color(0xFFE24B4A) : const Color(0xFF3B6D11);

  Color get _selectedFillColor =>
      _isBelum ? const Color(0xFFFCEBEB) : const Color(0xFFEAF3DE);

  Color get _selectedTextColor =>
      _isBelum ? const Color(0xFFA32D2D) : const Color(0xFF27500A);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: status.label,
      hint: status.description,
      selected: isSelected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? _selectedFillColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _selectedBorderColor : const Color(0xFFD9D9D9),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Radio indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? _selectedBorderColor
                            : const Color(0xFFBBBBBB),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? _selectedBorderColor
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Ikon status
                  Icon(
                    _isBelum
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 16,
                    color: isSelected
                        ? _selectedBorderColor
                        : const Color(0xFFAAAAAA),
                  ),
                  const SizedBox(width: 6),

                  // Label & deskripsi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.label,
                          style: semibold12.copyWith(
                            color: isSelected ? _selectedTextColor : dark1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          status.description,
                          style: regular14.copyWith(
                            fontSize: 10,
                            color: isSelected
                                ? _selectedTextColor.withOpacity(0.75)
                                : Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StatusPenanganan status;

  const _StatusBadge({required this.status});

  bool get _isBelum => status == StatusPenanganan.belumDitangani;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(status),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _isBelum ? const Color(0xFFFCEBEB) : const Color(0xFFEAF3DE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isBelum
                    ? const Color(0xFFE24B4A)
                    : const Color(0xFF639922),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              status.label,
              style: regular14.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isBelum
                    ? const Color(0xFFA32D2D)
                    : const Color(0xFF27500A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
