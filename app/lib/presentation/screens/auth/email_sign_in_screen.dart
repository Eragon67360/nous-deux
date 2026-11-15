import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/auth_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';

/// Email and password sign-in, for accounts created for people (store
/// reviewers, testers). There is no sign-up here: the server refuses it.
/// Once signed in, the router moves on to onboarding or the app.
class EmailSignInScreen extends ConsumerStatefulWidget {
  const EmailSignInScreen({super.key});

  @override
  ConsumerState<EmailSignInScreen> createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends ConsumerState<EmailSignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn(String lang) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = authEmailErrorEmpty(lang));
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithEmail(email: email, password: password);
    if (!mounted) return;
    setState(() => _loading = false);
    final failure = result.failure;
    if (failure != null) {
      // Server messages are in English and may say too much: keep to two.
      setState(
        () => _error = failure is WrongCredentialsFailure
            ? authEmailErrorWrong(lang)
            : authErrorGeneric(lang),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = ref.watch(deviceLanguageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(authEmailTitle(lang))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                Text(authEmailIntro(lang), style: theme.textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: authEmailLabel(lang)),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _loading ? null : _signIn(lang),
                  decoration: InputDecoration(
                    labelText: authPasswordLabel(lang),
                    errorText: _error,
                    errorMaxLines: 3,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: _loading ? null : () => _signIn(lang),
                  child: _loading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(authEmailButton(lang)),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
