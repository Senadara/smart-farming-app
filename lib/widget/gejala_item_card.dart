import 'package:flutter/material.dart';
import 'package:smart_farming_app/model/gejala_model.dart';
import 'package:smart_farming_app/theme.dart';

class GejalaItemCard extends StatelessWidget {
  final GejalaModel gejala;
  final bool isSelected;
  final VoidCallback onTap;

  const GejalaItemCard({
    super.key,
    required this.gejala,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "[GejalaItemCard] Rendering: ${gejala.namaGejala} (${gejala.gambar})");
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:
              isSelected ? green1.withOpacity(0.12) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? green1 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Checkbox di pojok kanan atas
            Positioned(
              top: 6,
              right: 6,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected ? green1 : Colors.white,
                  border: Border.all(
                    color: isSelected ? green1 : Colors.grey.shade400,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            // Konten: image + label
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (gejala.directGambarUrl.isNotEmpty)
                    Image.network(
                      gejala.directGambarUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 56,
                          height: 56,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    )
                  else
                    const Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      gejala.namaGejala,
                      textAlign: TextAlign.center,
                      style: regular12.copyWith(
                        color: isSelected ? green1 : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
