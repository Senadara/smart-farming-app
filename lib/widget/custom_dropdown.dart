import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme/telkom_theme.dart';

enum DropdownType { input, filter }

class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel;
  final String? hintText;
  final DropdownType type;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.itemLabel,
    this.hintText,
    this.type = DropdownType.input,
  });

  @override
  Widget build(BuildContext context) {
    final isFilter = type == DropdownType.filter;

    return Container(
      padding: isFilter
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
          : null,
      decoration: BoxDecoration(
        color: isFilter ? TelkomColors.card : null,
        border: isFilter
            ? Border.all(color: TelkomColors.border)
            : Border.all(color: TelkomColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: !isFilter,
          value: selectedItem,
          hint: Text(hintText ?? 'Pilih'),
          onChanged: onChanged,
          items: items.map((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(itemLabel(value)),
            );
          }).toList(),
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
}
