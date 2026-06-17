import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

bool isTutorialCompleted(SharedPreferences prefs, String screenKey) {
  return prefs.getBool('tutorial_${screenKey}_completed') ?? false;
}

Future<void> markTutorialCompleted(SharedPreferences prefs, String screenKey) {
  return prefs.setBool('tutorial_${screenKey}_completed', true);
}

Future<void> resetAllTutorials(SharedPreferences prefs) async {
  final keys = prefs.getKeys().where((k) => k.startsWith('tutorial_'));
  for (final key in keys) {
    await prefs.remove(key);
  }
}
