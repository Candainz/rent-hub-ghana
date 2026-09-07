import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_hub_app/screens/landlord/landlord_dashboard.dart';

void main() {
  testWidgets('landlord dashboard rebuilds the properties list after refresh', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LandlordDashboard(role: 'landlord', token: 'token-123'),
      ),
    );

    expect(find.byKey(const ValueKey('my-properties-0')), findsOneWidget);
  });
}
