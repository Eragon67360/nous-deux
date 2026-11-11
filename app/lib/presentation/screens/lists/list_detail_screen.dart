import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/lists_strings.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/domain/entities/shared_list_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/lists_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/lists/lists_screen.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';
import 'package:nousdeux/presentation/widgets/empty_state.dart';

class ListDetailScreen extends ConsumerStatefulWidget {
  const ListDetailScreen({super.key, required this.listId});

  final String listId;

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

enum _Menu { rename, delete }

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  bool _adding = false;

  /// Items swiped away whose delete waits for the undo snackbar to close.
  final _hidden = <String>{};

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _lang => ref.read(myProfileProvider).valueOrNull?.language ?? 'fr';

  void _report(Object? failure) {
    if (failure == null || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(listsError(_lang))));
  }

  /// The text stays in the field until the item is saved, so a failed add
  /// can be sent again as is.
  Future<void> _add() async {
    final text = _input.text.trim();
    if (text.isEmpty || _adding) return;
    _adding = true;
    final failure = await ref
        .read(listsRepositoryProvider)
        .addItem(widget.listId, text);
    _adding = false;
    if (!mounted) return;
    if (failure != null) return _report(failure);
    if (_input.text.trim() == text) _input.clear();
    _focus.requestFocus();
  }

  Future<void> _toggle(ListItemEntity item) async {
    HapticFeedback.selectionClick();
    final failure = await ref
        .read(listsRepositoryProvider)
        .setChecked(item.id, !item.checked);
    _report(failure);
  }

  /// Hides the item at once and deletes it when the snackbar closes, unless
  /// Undo was pressed. If the delete fails, the item comes back.
  void _delete(ListItemEntity item) {
    HapticFeedback.lightImpact();
    final lang = _lang;
    final repo = ref.read(listsRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _hidden.add(item.id));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(listsItemDeleted(lang, item.text)),
          // Times out like a plain snackbar, so the delete goes through.
          persist: false,
          action: SnackBarAction(label: listsUndo(lang), onPressed: () {}),
        ),
      ).closed.then((reason) async {
        if (reason == SnackBarClosedReason.action) {
          if (mounted) setState(() => _hidden.remove(item.id));
          return;
        }
        final failure = await repo.deleteItem(item.id);
        if (failure == null) return;
        if (mounted) setState(() => _hidden.remove(item.id));
        messenger.showSnackBar(SnackBar(content: Text(listsError(lang))));
      });
  }

  Future<void> _clearChecked() async {
    HapticFeedback.lightImpact();
    final failure = await ref
        .read(listsRepositoryProvider)
        .clearChecked(widget.listId);
    _report(failure);
  }

  Future<void> _onMenu(_Menu choice, SharedListEntity list) async {
    final lang = _lang;
    switch (choice) {
      case _Menu.rename:
        await showListEditor(context, ref, lang: lang, existing: list);
      case _Menu.delete:
        final ok = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(listsDelete(lang)),
            content: Text(listsDeleteConfirm(lang, list.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(listsCancel(lang)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(dialogContext).colorScheme.error,
                ),
                child: Text(listsDelete(lang)),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
        final failure = await ref
            .read(listsRepositoryProvider)
            .deleteList(list.id);
        if (failure != null) return _report(failure);
        if (mounted) _leave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final listsAsync = ref.watch(sharedListsProvider);
    final lists = listsAsync.valueOrNull ?? const [];
    final list = lists.where((l) => l.id == widget.listId).firstOrNull;
    if (list == null && listsAsync.hasValue && !listsAsync.isLoading) {
      return _gone(lang);
    }
    final items = ref
        .watch(listItemsProvider(widget.listId))
        .where((i) => !_hidden.contains(i.id))
        .toList();
    final open = items.where((i) => !i.checked).toList();
    final done = items.where((i) => i.checked).toList();

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (list != null)
            PopupMenuButton<_Menu>(
              tooltip: listsOptions(lang),
              onSelected: (choice) => _onMenu(choice, list),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _Menu.rename,
                  child: Text(listsRename(lang)),
                ),
                PopupMenuItem(
                  value: _Menu.delete,
                  child: Text(listsDelete(lang)),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md - 4,
          0,
          AppSpacing.md - 4,
          AppSpacing.xl,
        ),
        children: [
          Text(list?.name ?? '', style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  focusNode: _focus,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  maxLength: 200,
                  onSubmitted: (_) => _add(),
                  decoration: InputDecoration(
                    labelText: listsAddLabel(lang),
                    hintText: listsAddHint(lang),
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                height: 56,
                child: IconButton.filled(
                  tooltip: listsAddButton(lang),
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                listsEmptyListBody(lang),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          for (final item in open) _itemRow(item, lang),
          if (done.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    listsChecked(lang, done.length),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _clearChecked,
                  child: Text(listsClearChecked(lang)),
                ),
              ],
            ),
            for (final item in done) _itemRow(item, lang),
          ],
        ],
      ),
    );
  }

  /// Deleted on the other phone while open here.
  Widget _gone(String lang) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: EmptyState(
          icon: Icons.playlist_remove_rounded,
          message: listsGoneTitle(lang),
          secondary: listsGoneBody(lang),
          actionLabel: listsAll(lang),
          actionIcon: Icons.checklist_rounded,
          onAction: _leave,
        ),
      ),
    );
  }

  /// Opened from a link there may be nothing to go back to.
  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.lists);
    }
  }

  Widget _itemRow(ListItemEntity item, String lang) {
    final theme = Theme.of(context);
    final myId = ref.watch(currentUserProvider).valueOrNull?.id;
    final mine = item.addedBy == myId;
    final me = ref.watch(myProfileProvider).valueOrNull?.username;
    final partner = ref.watch(partnerProfileProvider).valueOrNull?.username;
    final author = (mine ? me : partner)?.trim() ?? '';
    final couple = CoupleColors.of(context);
    final tint = mine ? theme.colorScheme.primary : couple.partner;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(item),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        color: theme.colorScheme.error.withValues(alpha: 0.2),
        child: Icon(Icons.delete_outline, color: theme.colorScheme.error),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.surfaceContainerHigh),
          ),
        ),
        // One node for the screen reader, with Delete as an action since
        // swiping isn't available to it.
        child: MergeSemantics(
          child: Semantics(
            customSemanticsActions: {
              CustomSemanticsAction(label: listsDeleteItem(lang)): () =>
                  _delete(item),
            },
            child: CheckboxListTile(
              value: item.checked,
              onChanged: (_) => _toggle(item),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: theme.colorScheme.primary,
              checkColor: theme.colorScheme.onPrimary,
              title: Text(
                item.text,
                style: item.checked
                    ? theme.textTheme.bodyLarge?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.8,
                        ),
                      )
                    : theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
              ),
              secondary: item.checked
                  ? null
                  : Tooltip(
                      message: mine
                          ? listsAddedByMe(lang)
                          : listsAddedBy(
                              lang,
                              author.isEmpty
                                  ? nousPartnerFallback(lang)
                                  : author,
                            ),
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: tint.withValues(alpha: 0.22),
                        child: Text(
                          author.isEmpty
                              ? '·'
                              : author.characters.first.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
