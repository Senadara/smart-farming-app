import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class DatePickerField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String label;
  final bool isRequired;
  final String? initialDate;

  const DatePickerField({
    super.key,
    this.onChanged,
    this.label = 'Tanggal',
    this.isRequired = false,
    this.initialDate,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Isi dengan tanggal awal jika disediakan
    if (widget.initialDate != null) {
      _dateController.text = widget.initialDate!;
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now, // Tidak bisa pilih tanggal masa depan
      helpText: 'Pilih Tanggal Kejadian',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        // Terapkan warna tema aplikasi ke date picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: green1,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: dark1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() => _dateController.text = formatted);
      widget.onChanged?.call(formatted);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label dengan tanda wajib
        Row(
          children: [
            Text(widget.label, style: bold16.copyWith(color: dark1)),
            if (widget.isRequired) ...[
              const SizedBox(width: 4),
              Text('*', style: bold16.copyWith(color: Colors.red)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          style: regular14.copyWith(color: dark1),
          decoration: InputDecoration(
            hintText: 'Pilih tanggal kejadian',
            hintStyle: regular14.copyWith(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade100,
            prefixIcon: Icon(Icons.calendar_today_outlined, color: green1, size: 20),
            suffixIcon: _dateController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, size: 18, color: Colors.grey.shade500),
                    onPressed: () {
                      setState(() => _dateController.clear());
                      widget.onChanged?.call('');
                    },
                    tooltip: 'Hapus tanggal',
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: green1, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
        ),
      ],
    );
  }
}