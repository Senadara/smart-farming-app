enum LivestockStatus { AVAILABLE, EMPTY, SICK, ALLEY }

class Ayam {
  final List<String> ayamIds;
  final LivestockStatus status;
  final String? displayLabel;

  Ayam({required this.ayamIds, required this.status, this.displayLabel});
}

List<List<Ayam>> generateAyamLayout({
  required int kapasitas,
  required int jumlah,
}) {
  const letters = ['A', 'B', 'C', 'G', 'D', 'E', 'F'];
  const effectiveCols = 6;

  final totalRows = (kapasitas / effectiveCols).ceil();

  int filled = jumlah;

  return List.generate(totalRows, (rowIndex) {
    final number = rowIndex + 1;

    return letters.map((letter) {
      if (letter == 'G') {
        return Ayam(
            ayamIds: ['$letter$number'],
            status: LivestockStatus.ALLEY,
            displayLabel: '$letter$number');
      }

      final status =
          filled > 0 ? LivestockStatus.AVAILABLE : LivestockStatus.EMPTY;
      if (filled > 0) filled--;

      return Ayam(
          ayamIds: ['$letter$number'],
          status: status,
          displayLabel: '$letter$number');
    }).toList();
  });
}

List<List<Ayam>> generateAyamLayoutFromApi({
  required List<dynamic> dataApi,
  required int kapasitas,
}) {
  const letters = ['A', 'B', 'C', 'G', 'D', 'E', 'F'];
  const effectiveCols = 6;

  // Menghitung baris berdasarkan kapasitas (kalau 0, pakai jumlah data api)
  final count = kapasitas > 0 ? kapasitas : dataApi.length;
  final totalRows = count > 0 ? (count / effectiveCols).ceil() : 0;

  int dataIndex = 0;

  return List.generate(totalRows, (rowIndex) {
    final number = rowIndex + 1;
    return letters.map((letter) {
      if (letter == 'G') {
        return Ayam(
            ayamIds: [],
            status: LivestockStatus.ALLEY,
            displayLabel: '$letter$number');
      }

      if (dataIndex < dataApi.length) {
        final item = dataApi[dataIndex];
        dataIndex++;
        return Ayam(
            ayamIds: [item['id'].toString()],
            status: LivestockStatus.AVAILABLE,
            displayLabel: '$letter$number');
      } else {
        return Ayam(
            ayamIds: [],
            status: LivestockStatus.EMPTY,
            displayLabel: '$letter$number');
      }
    }).toList();
  });
}
