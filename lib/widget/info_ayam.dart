import 'package:flutter/material.dart';

class InfoAyam extends StatelessWidget {
  const InfoAyam({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text("Tersedia")
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text("Kosong")
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text("Sakit")
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text("Terpilih")
            ],
          ),
        ],
      ),
    );
  }
}
