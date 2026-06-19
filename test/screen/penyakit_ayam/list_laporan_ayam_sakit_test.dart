import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/list_laporan_ayam_sakit.dart';
import 'package:smart_farming_app/widget/header.dart';

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: '''
BASE_URL=http://localhost:3000
''');
  });

  testWidgets('ListLaporanAyamSakitScreen renders crucial UI components', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ListLaporanAyamSakitScreen(unitId: '1'),
    ));

    expect(find.byType(Header), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
