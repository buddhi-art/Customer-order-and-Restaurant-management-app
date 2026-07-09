import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/settings_repository.dart';
import '../models/settings.dart';

/// FutureProvider that exposes cafe settings (tax rate, currency, etc.) to
/// the rest of the app. Reads from the `cafe_settings` table via
/// [SettingsRepository] — no provider may import `supabase_flutter` directly.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(),
);

final settingsProvider = FutureProvider<CafeSettings>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.fetchSettings();
});
