import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/pilih_gejala_edit_screen.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/banner.dart';

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: '''
BASE_URL=http://localhost:3000
''');
  });

  testWidgets('PilihGejalaEditScreen renders crucial UI components', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PilihGejalaEditScreen(),
    ));

    expect(find.byType(Header), findsOneWidget);
    expect(find.byType(BannerWidget), findsOneWidget);
  });
}
