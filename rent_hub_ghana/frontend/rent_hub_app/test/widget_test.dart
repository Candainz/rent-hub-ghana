// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:rent_hub_app/main.dart';

void main() {
  testWidgets('starts with role selection and requires renter auth', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RentHubApp());
    expect(find.text('Let’s find your place'), findsOneWidget);
    expect(find.text('I’m looking for a home'), findsOneWidget);
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Rent Hub'), findsOneWidget);
    expect(find.text('Log in securely'), findsOneWidget);
    expect(find.text('Create free account'), findsOneWidget);
  });

  testWidgets('routes property owners to auth before workspace', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RentHubApp());
    await tester.tap(find.text('I have a property'));
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Rent Hub'), findsOneWidget);
    expect(find.text('Create free account'), findsOneWidget);
  });

  testWidgets('returns to role selection from account access', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RentHubApp());
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change role'));
    await tester.pumpAndSettle();
    expect(find.text('Let’s find your place'), findsOneWidget);
    expect(find.text('I have a property'), findsOneWidget);
  });

  testWidgets('shows password reset flow when forgot password is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RentHubApp());
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log in securely'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Reset your password'), findsOneWidget);
    expect(find.text('Get recovery question'), findsOneWidget);
  });
}
