import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/lists_strings.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/domain/entities/shared_list_entity.dart';
import 'package:nousdeux/presentation/screens/lists/list_detail_screen.dart';
import 'package:nousdeux/presentation/screens/lists/lists_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

const _groceries = SharedListEntity(
  id: 'groceries',
  coupleId: coupleId,
  name: 'Courses',
  icon: ListIcon.cart,
  createdBy: meId,
);

ListItemEntity _item(String id, {bool checked = false, String by = meId, int minute = 0}) =>
    ListItemEntity(
      id: id,
      listId: 'groceries',
      text: id,
      checked: checked,
      addedBy: by,
      createdAt: DateTime(2026, 11, 10, 9, minute),
    );

TestDeps _deps({List<SharedListEntity>? lists, List<ListItemEntity>? items}) => TestDeps(
  myProfile: profile(partner: partnerId, username: 'Thomas'),
  partner: partnerProfile(username: 'Camille'),
  couple: couple(pairingCode: null),
  lists: lists ?? [_groceries],
  listItems: items,
);

Future<void> _pumpLists(WidgetTester tester, TestDeps deps) => pumpRouter(
  tester,
  deps: deps,
  initialLocation: AppRoutes.lists,
  routes: [
    screenRoute(AppRoutes.lists, const ListsScreen()),
    stubRoute(AppRoutes.listDetail('groceries')),
  ],
).then((_) {});

Future<void> _pumpDetail(WidgetTester tester, TestDeps deps) => pumpRouter(
  tester,
  deps: deps,
  initialLocation: AppRoutes.listDetail('groceries'),
  routes: [
    stubRoute(AppRoutes.lists),
    screenRoute(
      AppRoutes.listDetail('groceries'),
      const ListDetailScreen(listId: 'groceries'),
    ),
  ],
).then((_) {});

void main() {
  group('ListsScreen', () {
    testWidgets('shows each list with what is left', (tester) async {
      await _pumpLists(
        tester,
        _deps(items: [_item('tomatoes'), _item('bread'), _item('milk', checked: true)]),
      );

      expect(find.text('Courses'), findsOneWidget);
      expect(find.text(listsCounts('fr', 2, 3)), findsOneWidget);
      expect(find.text(listsSubtitle('fr', 'Camille')), findsOneWidget);
    });

    testWidgets('empty state when there is no list yet', (tester) async {
      await _pumpLists(tester, _deps(lists: []));
      expect(find.text(listsEmptyTitle('fr')), findsOneWidget);
    });

    testWidgets('creates a list with a name and an icon', (tester) async {
      final deps = _deps(lists: []);
      await _pumpLists(tester, deps);

      await tester.tap(find.text(listsNew('fr')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  Idées de week-end ');
      await tester.tap(find.byTooltip(listsIconName('fr', ListIcon.star)));
      await tester.tap(find.text(listsCreate('fr')));
      await tester.pumpAndSettle();

      expect(deps.lists.calls, ['create:Idées de week-end:star']);
      expect(find.text('Idées de week-end'), findsOneWidget);
    });

    testWidgets('a blank name creates nothing', (tester) async {
      final deps = _deps(lists: []);
      await _pumpLists(tester, deps);

      await tester.tap(find.text(listsNew('fr')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text(listsCreate('fr')));
      await tester.pumpAndSettle();

      expect(deps.lists.calls, isEmpty);
    });
  });

  group('ListDetailScreen', () {
    testWidgets('adds an item and clears the field', (tester) async {
      final deps = _deps();
      await _pumpDetail(tester, deps);

      await tester.enterText(find.byType(TextField), " Lait d'avoine ");
      await tester.tap(find.byTooltip(listsAddButton('fr')));
      await tester.pumpAndSettle();

      expect(deps.lists.calls, ["add:groceries:Lait d'avoine"]);
      expect(find.text("Lait d'avoine"), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });

    testWidgets('ticking moves an item to the ticked section', (tester) async {
      final deps = _deps(items: [_item('tomatoes'), _item('bread', minute: 1)]);
      await _pumpDetail(tester, deps);

      await tester.tap(find.text('tomatoes'));
      await tester.pumpAndSettle();

      expect(deps.lists.calls, ['check:tomatoes:true']);
      expect(find.text(listsChecked('fr', 1)), findsOneWidget);
    });

    testWidgets('clear all removes the ticked items only', (tester) async {
      final deps = _deps(items: [_item('tomatoes'), _item('milk', checked: true)]);
      await _pumpDetail(tester, deps);

      await tester.tap(find.text(listsClearChecked('fr')));
      await tester.pumpAndSettle();

      expect(deps.lists.calls, ['clear:groceries']);
      expect(find.text('milk'), findsNothing);
      expect(find.text('tomatoes'), findsOneWidget);
    });

    testWidgets("says who added each item", (tester) async {
      await _pumpDetail(
        tester,
        _deps(items: [_item('tomatoes', by: partnerId), _item('bread', minute: 1)]),
      );

      expect(find.byTooltip(listsAddedBy('fr', 'Camille')), findsOneWidget);
      expect(find.byTooltip(listsAddedByMe('fr')), findsOneWidget);
    });

    testWidgets('swiping an item deletes it', (tester) async {
      final deps = _deps(items: [_item('tomatoes')]);
      await _pumpDetail(tester, deps);

      await tester.drag(find.text('tomatoes'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(deps.lists.calls, ['deleteItem:tomatoes']);
    });

    testWidgets('deleting the list asks first, then goes back', (tester) async {
      final deps = _deps();
      await _pumpDetail(tester, deps);

      await tester.tap(find.byTooltip(listsOptions('fr')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(listsDelete('fr')).last);
      await tester.pumpAndSettle();
      expect(find.text(listsDeleteConfirm('fr', 'Courses')), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, listsDelete('fr')));
      await tester.pumpAndSettle();

      expect(deps.lists.calls, ['deleteList:groceries']);
    });
  });
}
