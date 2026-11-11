import 'package:flutter/material.dart';

/// Small gold capitals that open a part of a notebook page.
class NotebookLabel extends StatelessWidget {
  const NotebookLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 11,
          letterSpacing: 2,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// The thin line between two parts of a notebook page.
class NotebookRule extends StatelessWidget {
  const NotebookRule({super.key, this.space = 22});

  /// Room above and below the line.
  final double space;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: space),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

/// A text link with a chevron, at least 44 px tall.
class NotebookLink extends StatelessWidget {
  const NotebookLink({
    super.key,
    required this.label,
    required this.onTap,
    this.quiet = false,
    this.back = false,
  });

  final String label;
  final VoidCallback onTap;

  /// Grey instead of gold.
  final bool quiet;

  /// The chevron points back, before the label.
  final bool back;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            back ? '‹ $label' : '$label ›',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: quiet ? scheme.onSurfaceVariant : scheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
