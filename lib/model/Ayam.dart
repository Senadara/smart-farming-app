import 'package:flutter/material.dart';

enum LivestockStatus { AVAILABLE, EMPTY, SICK, ALLEY }

class Ayam {
  final List<String> ayamIds;
  final LivestockStatus status;
  final String? displayLabel;
  final String? sickStatus;

  Ayam({
    required this.ayamIds,
    required this.status,
    this.displayLabel,
    this.sickStatus,
  });
}

String getAyamLabelFromNamaId(String namaId) {
  const effectiveLetters = ['A', 'B', 'C', 'D', 'E', 'F'];
  final match = RegExp(r'#(\d+)$').firstMatch(namaId);
  if (match == null) return namaId;

  final n = int.tryParse(match.group(1)!) ?? 0;
  if (n <= 0) return namaId;

  final idx = n - 1;
  final row = (idx ~/ 6) + 1;
  final col = idx % 6;
  return '${effectiveLetters[col]}$row';
}

const _kLetters = ['A', 'B', 'C', 'G', 'D', 'E', 'F'];
const _kEffectiveCols = 6;

List<List<Ayam>> _generateLayout({
  required int totalCount,
  required Ayam Function(int index, String letter, int number) cellBuilder,
}) {
  final totalRows = totalCount > 0 ? (totalCount / _kEffectiveCols).ceil() : 0;

  var index = 0;
  return List.generate(totalRows, (rowIndex) {
    final number = rowIndex + 1;
    return _kLetters.map((letter) {
      if (letter == 'G') {
        return Ayam(
          ayamIds: const [],
          status: LivestockStatus.ALLEY,
          displayLabel: '$letter$number',
        );
      }
      return cellBuilder(index++, letter, number);
    }).toList();
  });
}

List<List<Ayam>> generateAyamLayout({
  required int kapasitas,
  required int jumlah,
}) {
  var filled = jumlah;

  return _generateLayout(
    totalCount: kapasitas,
    cellBuilder: (index, letter, number) {
      final status =
          filled > 0 ? LivestockStatus.AVAILABLE : LivestockStatus.EMPTY;
      if (filled > 0) filled--;

      return Ayam(
        ayamIds: ['$letter$number'],
        status: status,
        displayLabel: '$letter$number',
      );
    },
  );
}

List<List<Ayam>> generateAyamLayoutFromApi({
  required List<dynamic> dataApi,
  required int kapasitas,
  Map<String, String> sickIds = const {},
}) {
  final totalCount = kapasitas > 0 ? kapasitas : dataApi.length;

  return _generateLayout(
    totalCount: totalCount,
    cellBuilder: (index, letter, number) {
      if (index >= dataApi.length) {
        return Ayam(
          ayamIds: const [],
          status: LivestockStatus.EMPTY,
          displayLabel: '$letter$number',
        );
      }

      final id = dataApi[index]['id'].toString();
      final isSick = sickIds.containsKey(id) && 
                     sickIds[id] != 'Sembuh' && 
                     sickIds[id] != 'Sudah ditangani';
    

      return Ayam(
        ayamIds: [id],
        status: isSick ? LivestockStatus.SICK : LivestockStatus.AVAILABLE,
        displayLabel: '$letter$number',
        sickStatus: isSick ? sickIds[id] : null,
      );
    },
  );
}