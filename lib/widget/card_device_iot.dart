import 'package:flutter/material.dart';

class CardDeviceIot extends StatelessWidget {
  final String title;
  final String status;
  final String? schedule;
  final String assetIcon;
  final bool isActive;
  final VoidCallback onTapPower;

  const CardDeviceIot({
    super.key,
    required this.title,
    required this.status,
    this.schedule,
    required this.assetIcon,
    required this.isActive,
    required this.onTapPower,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5E5),
        borderRadius: BorderRadius.circular(16),
      ),

      // >>> seluruh row dicenterkan secara vertical
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ==== ICON ====
          Image.asset(
            assetIcon,
            width: 80,
            height: 80,
          ),

          const SizedBox(width: 12),

          // ==== MIDDLE CONTENT ====
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // CENTER VERTICAL
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // STATUS
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // SCHEDULE
                    if (schedule != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          schedule!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ==== POWER BUTTON CENTER VERTICAL ====
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.power_settings_new_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
