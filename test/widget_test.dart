import 'package:flutter_test/flutter_test.dart';
import 'package:selah/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SelahApp());

    // Verify the app loads with the Today tab visible
    expect(find.text('Today'), findsWidgets);
  });
}
