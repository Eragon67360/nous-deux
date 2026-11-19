import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/update_strings.dart';
import 'package:nousdeux/core/services/store_links.dart';
import 'package:nousdeux/domain/app_update.dart';
import 'package:nousdeux/presentation/providers/app_update_provider.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';
import 'package:nousdeux/presentation/widgets/merging_rings.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// Shows the update screen over [child] when a newer build is out or this
/// one is too old (docs/UPDATE_SCREEN.md). Checks again each time the app
/// comes back.
class UpdateGate extends ConsumerStatefulWidget {
  const UpdateGate({super.key, required this.child});

  final Widget? child;

  @override
  ConsumerState<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends ConsumerState<UpdateGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(updateFactsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The page underneath gives up the keyboard when the screen shows.
    ref.listen(updateOfferProvider, (previous, next) {
      if (previous == null && next != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
    final offer = ref.watch(updateOfferProvider);
    return Stack(
      children: [
        // The app stays underneath, out of reach while the screen shows.
        ExcludeSemantics(
          excluding: offer != null,
          child: widget.child ?? const SizedBox.shrink(),
        ),
        if (offer != null) Positioned.fill(child: UpdateScreen(offer: offer)),
      ],
    );
  }
}

/// Board 1 (a newer build, « Plus tard ») or board 2 (too old, no way past).
class UpdateScreen extends ConsumerWidget {
  const UpdateScreen({super.key, required this.offer});

  final UpdateOffer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLocaleProvider).languageCode;
    final theme = Theme.of(context);
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    final offer = this.offer;
    final latest = offer is UpdateAvailable ? offer : null;
    final title = latest != null
        ? updateTitle(lang)
        : updateRequiredTitle(lang);
    final body = latest != null
        ? (latest.note ?? updateBodyDefault(lang))
        : updateRequiredBody(lang);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
    );

    // At the largest text sizes the build goes under its label.
    Widget row(String label, String value, {bool bright = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 16,
        runSpacing: 4,
        children: [
          Text(label, style: muted),
          Text(
            value,
            style: bright
                ? muted?.copyWith(color: theme.colorScheme.onSurface)
                : muted,
          ),
        ],
      ),
    );

    return Material(
      color: theme.colorScheme.surface,
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: title,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 56,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: MergingRings(size: 64),
                      ),
                      const SizedBox(height: 40),
                      NotebookLabel(
                        latest != null
                            ? updateLabel(lang)
                            : updateRequiredLabel(lang),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        body,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const NotebookRule(space: 0),
                      row(
                        updateYourVersion(lang),
                        updateBuild(lang, offer.installed),
                      ),
                      if (latest != null) ...[
                        const NotebookRule(space: 0),
                        row(
                          updateLatestVersion(lang),
                          updateBuild(lang, latest.latest),
                          bright: true,
                        ),
                      ],
                      const NotebookRule(space: 0),
                      const Spacer(),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: () => openStore(
                          ref.read(openExternalLinkProvider),
                          isIos: isIos,
                        ),
                        child: Text(updateButton(lang)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        updateOpens(lang, isIos: isIos),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      if (latest != null) ...[
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => ref.read(postponeUpdateProvider)(),
                          child: Text(updateLater(lang)),
                        ),
                      ],
                    ],
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
