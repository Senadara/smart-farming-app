import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/delete_gejala_screen.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/banner.dart';

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: '''
BASE_URL=http://localhost:3000
''');
  });

  testWidgets('DeleteGejalaScreen renders crucial UI components', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DeleteGejalaScreen(),
    ));

    // Verify app bar / header exists
    expect(find.byType(Header), findsOneWidget);
    
    // Verify BannerWidget exists
    expect(find.byType(BannerWidget), findsOneWidget);
    
    // The screen initially shows a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
