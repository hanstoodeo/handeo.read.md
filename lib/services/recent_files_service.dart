import 'package:shared_preferences/shared_preferences.dart';

class RecentFilesService {
  static const _key = 'recent_files';
  static const _maxFiles = 10;

  static Future<List<String>> getRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addRecentFile(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final files = prefs.getStringList(_key) ?? [];

    // Remove if already exists (move to top)
    files.remove(path);
    files.insert(0, path);

    // Keep only the latest N files
    if (files.length > _maxFiles) {
      files.removeRange(_maxFiles, files.length);
    }

    await prefs.setStringList(_key, files);
  }

  static Future<void> removeRecentFile(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final files = prefs.getStringList(_key) ?? [];
    files.remove(path);
    await prefs.setStringList(_key, files);
  }

  static Future<void> clearRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
