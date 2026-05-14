import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

/// Controlled TagInputField — read-only, tag hanya dari luar.
/// Mendukung empty state, hapus per-tag, dan hapus semua.
class TagInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final List<String> tags;
  final ValueChanged<List<String>>? onTagsChanged;
  final Color? accentColor;
  final int? maxTags;
  final bool showClearAll;

  const TagInputField({
    super.key,
    this.label = '',
    this.placeholder = 'Belum ada gejala dipilih...',
    this.tags = const [],
    this.onTagsChanged,
    this.accentColor,
    this.maxTags,
    this.showClearAll = true,
  });

  static const _surface      = Colors.white;
  static final  _borderColor = const Color(0xFFD9D9D9);
  static final  _deleteColor = const Color(0xFF999798);

  Color get _accent => accentColor ?? green1;
  Color get _tagBg  => _accent.withOpacity(0.08);

  void _removeTag(String tag) =>
      onTagsChanged?.call(tags.where((t) => t != tag).toList());

  void _clearAll() => onTagsChanged?.call([]);

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = tags.isEmpty;
    final bool maxReached = maxTags != null && tags.length >= maxTags!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label row ──────────────────────────────────────────
        if (label.isNotEmpty)
          Row(
            children: [
              Text(label, style: medium14.copyWith(color: dark1)),
              const Spacer(),
              // Counter badge
              if (!isEmpty)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    key: ValueKey(tags.length),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: maxReached
                              ? Colors.orange.withOpacity(0.12)
                              : _accent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          maxTags != null
                              ? '${tags.length}/$maxTags'
                              : '${tags.length} dipilih',
                          style: medium12.copyWith(
                            color: maxReached ? Colors.orange : _accent,
                          ),
                        ),
                      ),
                      if (showClearAll) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _clearAll,
                          child: Text(
                            'Hapus semua',
                            style: regular12.copyWith(color: dark3),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        if (label.isNotEmpty) const SizedBox(height: 8),

        // ── Container ──────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            color: isEmpty ? const Color(0xFFFAFAFA) : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEmpty ? _borderColor : _accent.withOpacity(0.3),
              width: isEmpty ? 1 : 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: isEmpty
              // ── Empty state ──────────────────────────────────
              ? Row(
                  children: [
                    Icon(Icons.label_outline_rounded,
                        size: 16, color: dark3.withOpacity(0.5)),
                    const SizedBox(width: 8),
                    Text(placeholder,
                        style: regular14.copyWith(
                            color: dark3.withOpacity(0.7))),
                  ],
                )
              // ── Tags ─────────────────────────────────────────
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags
                      .map((tag) => _TagChip(
                            key: ValueKey(tag),
                            label: tag,
                            onDelete: () => _removeTag(tag),
                            accentColor: _accent,
                            bgColor: _tagBg,
                            deleteColor: _deleteColor,
                          ))
                      .toList(),
                ),
        ),

        // ── Max warning ───────────────────────────────────────
        if (maxReached)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 13, color: Colors.orange.shade700),
                const SizedBox(width: 4),
                Text(
                  'Batas maksimal gejala tercapai',
                  style: regular12.copyWith(color: Colors.orange.shade700),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Tag Chip dengan animasi masuk
// ─────────────────────────────────────────────

class _TagChip extends StatefulWidget {
  final String label;
  final VoidCallback onDelete;
  final Color accentColor;
  final Color bgColor;
  final Color deleteColor;

  const _TagChip({
    super.key,
    required this.label,
    required this.onDelete,
    required this.accentColor,
    required this.bgColor,
    required this.deleteColor,
  });

  @override
  State<_TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<_TagChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _scale   = CurvedAnimation(parent: _anim, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding:
              const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 6),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: widget.accentColor.withOpacity(0.25), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: medium12.copyWith(color: widget.accentColor),
              ),
              const SizedBox(width: 4),
              // Tombol hapus dengan ripple area lebih besar
              GestureDetector(
                onTap: widget.onDelete,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(Icons.close_rounded,
                      size: 13, color: widget.deleteColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}