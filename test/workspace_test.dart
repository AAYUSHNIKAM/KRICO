import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sports_app/design_system/layouts/lazy_tab_stack.dart';
import 'package:sports_app/design_system/layouts/premium_shell.dart';
import 'package:sports_app/features/home/presentation/workspace_destinations.dart';
import 'package:sports_app/features/home/presentation/workspace_home.dart';
import 'package:sports_app/models/user_model.dart';

void main() {
  test('Players and parents have booking-first primary navigation', () {
    for (final role in [UserRole.player, UserRole.parent]) {
      expect(workspaceDestinations(role).take(4).map((d) => d.id), [
        'home',
        'discover',
        'bookings',
        'messages',
      ]);
    }
    expect(workspaceDestinations(UserRole.coach).take(5).map((d) => d.id), [
      'home',
      'requests',
      'schedule',
      'students',
      'messages',
    ]);
  });

  test('All roles retain account tools and unique destinations', () {
    for (final role in UserRole.values) {
      final ids = workspaceDestinations(role).map((d) => d.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, containsAll(['profile', 'contracts', 'messages']));
      expect(ids.length, greaterThanOrEqualTo(5));
    }
    expect(
      workspaceDestinations(UserRole.player).map((d) => d.id),
      containsAll([
        'growth',
        'performance',
        'video',
        'squad',
        'challenges',
        'community',
      ]),
    );
    expect(
      workspaceDestinations(UserRole.academy).map((d) => d.id),
      containsAll(['batches', 'coaches', 'jobs', 'advertising', 'overview']),
    );
  });

  testWidgets('Lazy tabs mount on demand and preserve visited state', (
    tester,
  ) async {
    var firstBuilds = 0;
    var secondBuilds = 0;
    final first = Builder(
      builder: (_) {
        firstBuilds++;
        return const Text('First');
      },
    );
    final second = Builder(
      builder: (_) {
        secondBuilds++;
        return const TextField();
      },
    );
    Future<void> show(int index) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LazyTabStack(index: index, children: [first, second]),
        ),
      ),
    );
    await show(0);
    expect(firstBuilds, 1);
    expect(secondBuilds, 0);
    await show(1);
    await tester.enterText(find.byType(TextField), 'Kept draft');
    await show(0);
    await show(1);
    expect(find.text('Kept draft'), findsOneWidget);
    expect(secondBuilds, 1);
  });

  for (final role in UserRole.values) {
    for (final width in [360.0, 800.0, 1280.0]) {
      testWidgets(
        '${role.name} workspace renders at width $width and primary action works',
        (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var selected = -1;
          final destinations = workspaceDestinations(role);
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                home: Scaffold(
                  body: WorkspaceNavigation(
                    select: (index) => selected = index,
                    child: WorkspaceHome(
                      user: UserModel(
                        uid: 'test',
                        email: 'test@example.com',
                        name: 'Test User',
                        phone: '',
                        role: role,
                      ),
                      destinations: destinations,
                    ),
                  ),
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          await tester.tap(
            find.widgetWithText(FilledButton, destinations[1].label).first,
          );
          expect(selected, 1);
          await tester.drag(find.byType(ListView).first, const Offset(0, -600));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
