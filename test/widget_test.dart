import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_app/core/theme/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  testWidgets('App launches and theme changes preserve the active route', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Coaching workspace')),
        ),
        GoRoute(
          path: '/bookings',
          builder: (_, _) => const Scaffold(body: Text('My bookings')),
        ),
      ],
    );
    addTearDown(router.dispose);
    final container = ProviderContainer(
      overrides: [appRouterProvider.overrideWithValue(router)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SportsEcoApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SportsEcoApp), findsOneWidget);
    expect(find.text('Coaching workspace'), findsOneWidget);
    router.go('/bookings');
    await tester.pumpAndSettle();
    await container.read(themeModeProvider.notifier).set(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(find.text('My bookings'), findsOneWidget);
  });
}
