import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/constants/app_radius.dart';
import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/lists_strings.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/domain/entities/shared_list_entity.dart';
import 'package:nousdeux/presentation/providers/lists_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/lists/list_icon.dart';
import 'package:nousdeux/presentation/widgets/empty_state.dart';
import 'package:nousdeux/presentation/widgets/entrance.dart';

class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final partner = ref
        .watch(partnerProfileProvider)
        .valueOrNull
        ?.username
        ?.trim();
    final lists = ref.watch(sharedListsProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showListEditor(context, ref, lang: lang),
        icon: const Icon(Icons.add),
        label: Text(listsNew(lang)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md - 4,
          0,
          AppSpacing.md - 4,
          AppSpacing.xl * 2,
        ),
        children: [
          Text(listsTitle(lang), style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            listsSubtitle(
              lang,
              (partner?.isNotEmpty ?? false)
                  ? partner!
                  : nousPartnerFallback(lang),
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (lists.isEmpty)
            EmptyState(
              icon: Icons.checklist_rounded,
              message: listsEmptyTitle(lang),
              secondary: listsEmptyBody(lang),
            )
          else
            for (final (i, list) in lists.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Entrance(
                  delay: Duration(milliseconds: 40 * i),
                  child: _ListCard(list: list, lang: lang),
                ),
              ),
        ],
      ),
    );
  }
}

class _ListCard extends ConsumerWidget {
  const _ListCard({required this.list, required this.lang});

  final SharedListEntity list;
  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final counts = ref.watch(listCountsProvider(list.id));
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.md + 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
        onTap: () => context.push(AppRoutes.listDetail(list.id)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 76),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                ListIconTile(list.icon),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        listsCounts(lang, counts.open, counts.total),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to create a list, or rename one when [existing] is given.
Future<void> showListEditor(
  BuildContext context,
  WidgetRef ref, {
  required String lang,
  SharedListEntity? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ListEditorSheet(lang: lang, existing: existing),
  );
}

class _ListEditorSheet extends ConsumerStatefulWidget {
  const _ListEditorSheet({required this.lang, this.existing});

  final String lang;
  final SharedListEntity? existing;

  @override
  ConsumerState<_ListEditorSheet> createState() => _ListEditorSheetState();
}

class _ListEditorSheetState extends ConsumerState<_ListEditorSheet> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late ListIcon _icon = widget.existing?.icon ?? ListIcon.cart;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(listsRepositoryProvider);
    final existing = widget.existing;
    final failure = existing == null
        ? (await repo.createList(name: name, icon: _icon)).failure
        : await repo.renameList(existing.id, name);
    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _saving = false;
        _error = listsError(widget.lang);
      });
      return;
    }
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final editing = widget.existing != null;
    // Scrolls when the keyboard and a large text size leave too little room.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md - 4,
        0,
        AppSpacing.md - 4,
        AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            editing ? listsRename(lang) : listsNew(lang),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: listsNameLabel(lang),
              hintText: listsNameHint(lang),
              errorText: _error,
            ),
          ),
          if (!editing) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              listsIconLabel(lang),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              children: [
                for (final icon in ListIcon.values)
                  ChoiceChip(
                    label: Icon(listIconData(icon), size: 20),
                    tooltip: listsIconName(lang, icon),
                    selected: _icon == icon,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _icon = icon),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(editing ? listsSave(lang) : listsCreate(lang)),
          ),
        ],
      ),
    );
  }
}
