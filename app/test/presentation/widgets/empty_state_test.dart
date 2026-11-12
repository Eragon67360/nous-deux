import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/presentation/widgets/empty_state.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('shows the icon and message', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: EmptyState(icon: Icons.event_note_outlined, message: 'Rien ici'),
      ),
    );

    expect(find.text('Rien ici'), findsOneWidget);
    expect(find.byIcon(Icons.event_note_outlined), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('shows the secondary line only when non-empty', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: EmptyState(
          icon: Icons.info,
          message: 'M',
          secondary: 'Plus tard',
        ),
      ),
    );
    expect(find.text('Plus tard'), findsOneWidget);

    await pumpScreen(
      tester,
      const Scaffold(
        body: EmptyState(icon: Icons.info, message: 'M', secondary: ''),
      ),
    );
    // Only the message remains.
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('the action button fires onAction', (tester) async {
    var taps = 0;
    await pumpScreen(
      tester,
      Scaffold(
        body: EmptyState(
          icon: Icons.info,
          message: 'M',
          actionLabel: 'Ajouter',
          onAction: () => taps++,
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget, reason: 'default icon');
    await tester.tap(find.text('Ajouter'));
    expect(taps, 1);
  });

  testWidgets('uses the given action icon', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: EmptyState(
          icon: Icons.info,
          message: 'M',
          actionLabel: 'Go',
          actionIcon: Icons.send,
          onAction: () {},
        ),
      ),
    );
    expect(find.byIcon(Icons.send), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('no button without both a label and a callback', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: EmptyState(icon: Icons.info, message: 'M', actionLabel: 'Go'),
      ),
    );
    expect(find.text('Go'), findsNothing);

    await pumpScreen(
      tester,
      Scaffold(
        body: EmptyState(icon: Icons.info, message: 'M', onAction: () {}),
      ),
    );
    expect(find.byType(FilledButton), findsNothing);
  });
}
