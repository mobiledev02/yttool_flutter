import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _historyKey = 'history_v2';
  static const String _favoritesKey = 'favorites_v2';

  Future<void> addToHistory(String url, String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    final newItem = jsonEncode({'url': url, 'title': title});

    // Remove if exists to move to top (check by URL)
    history.removeWhere((item) {
      try {
        final decoded = jsonDecode(item);
        return decoded['url'] == url;
      } catch (e) {
        return item == url; // Backward compatibility
      }
    });

    history.insert(0, newItem);

    // Limit to 50 items
    if (history.length > 50) {
      history = history.sublist(0, 50);
    }

    await prefs.setStringList(_historyKey, history);
  }

  Future<List<Map<String, String>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawHistory = prefs.getStringList(_historyKey) ?? [];

    return rawHistory.map((item) {
      try {
        final decoded = jsonDecode(item);
        return {
          'url': decoded['url'] as String,
          'title': decoded['title'] as String,
        };
      } catch (e) {
        // Handle old format (just URL)
        return {'url': item, 'title': item};
      }
    }).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> toggleFavorite(String url, String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

    final existingIndex = favorites.indexWhere((item) {
      try {
        final decoded = jsonDecode(item);
        return decoded['url'] == url;
      } catch (e) {
        return item == url;
      }
    });

    if (existingIndex != -1) {
      favorites.removeAt(existingIndex);
    } else {
      favorites.add(jsonEncode({'url': url, 'title': title}));
    }

    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<bool> isFavorite(String url) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

    return favorites.any((item) {
      try {
        final decoded = jsonDecode(item);
        return decoded['url'] == url;
      } catch (e) {
        return item == url;
      }
    });
  }

  Future<List<Map<String, String>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawFavorites = prefs.getStringList(_favoritesKey) ?? [];

    return rawFavorites.map((item) {
      try {
        final decoded = jsonDecode(item);
        return {
          'url': decoded['url'] as String,
          'title': decoded['title'] as String,
        };
      } catch (e) {
        return {'url': item, 'title': item};
      }
    }).toList();
  }
}
