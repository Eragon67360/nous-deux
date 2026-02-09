import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Your existing imports for context
import 'package:nousdeux/core/constants/period_reminder_prefs.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

// --- Avatar Controller ---
class AvatarController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> pickAndUploadAvatar(BuildContext context) async {
    final userId = ref.read(currentUserProvider).valueOrNull?.id;
    if (userId == null) return;

    state = const AsyncLoading();

    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (xfile == null) {
        state = const AsyncData(null);
        return;
      }

      final file = File(xfile.path);
      if (!await file.exists()) return;

      final client = Supabase.instance.client;
      const bucket = 'avatars';
      final path = '$userId/avatar.jpg';

      // Upload
      await client.storage
          .from(bucket)
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      // Get URL
      final publicUrl = client.storage.from(bucket).getPublicUrl(path);

      // Update DB
      final result = await ref
          .read(profileRepositoryProvider)
          .updateProfile(avatarUrl: publicUrl);

      if (result.failure != null) {
        throw Exception(result.failure!.message);
      }

      ref.invalidate(myProfileProvider);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

final avatarControllerProvider =
    AsyncNotifierProvider.autoDispose<AvatarController, void>(
      AvatarController.new,
    );

// --- Permissions Stream (Auto-refreshes on App Resume) ---
final permissionsProvider =
    StreamProvider.autoDispose<Map<Permission, PermissionStatus>>((ref) {
      Future<Map<Permission, PermissionStatus>> fetchStatuses() async {
        final perms = [
          Permission.calendar,
          Permission.notification,
          Permission.location,
          Permission.camera,
        ];
        final result = <Permission, PermissionStatus>{};
        for (final p in perms) {
          result[p] = await p.status;
        }
        return result;
      }

      // Yield initial statuses. Invalidate this provider after returning from
      // app settings to refresh (e.g. from the settings screen on resume).
      return Stream.fromFuture(fetchStatuses());
    });

// --- Calendar Preferences Controller ---
class CalendarPrefsController extends AutoDisposeAsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(calendarNotificationsEnabledKey) ?? false;
  }

  Future<void> toggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(calendarNotificationsEnabledKey, value);
    state = AsyncData(value);
  }
}

final calendarPrefsProvider =
    AsyncNotifierProvider.autoDispose<CalendarPrefsController, bool>(
      CalendarPrefsController.new,
    );
