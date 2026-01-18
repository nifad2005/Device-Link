import 'package:flutter_test/flutter_test.dart';
import 'package:device_linker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DeviceLinkerApp());

    // Verify that the brand name is present.
    expect(find.text('Device Linker'), findsOneWidget);
    expect(find.text('Pair New Device'), findsOneWidget);
  });
}
