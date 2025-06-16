// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin class BaseStorage {
  String get boxName => '';

  GetStorage? box;
  SharedPreferences? _prefs;
  bool get isWeb => kIsWeb;

  Future<void> ensureInitStorage() async {
    if (!isWeb && box != null) {
      return;
    }

    if (isWeb) {
      _prefs = await SharedPreferences.getInstance();
    } else {
      await GetStorage.init(boxName);
      box = GetStorage(boxName);
    }
  }

  String _getKey(String key) => '$boxName:$key';

  @protected
  Future<T?> read<T>(String key) async {
    await ensureInitStorage();

    try {
      if (isWeb) {
        if (_prefs == null) return null;

        final value = _prefs!.get(_getKey(key));
        if (value == null) return null;

        // Handle primitive types
        if (T == String) return value as T;
        if (T == bool) return value as T;
        if (T == int) return value as T;
        if (T == double) return value as T;

        // Handle complex types (Map, List)
        if (value is String) {
          return json.decode(value) as T;
        }
        return value as T;
      }
      return box!.read(key);
    } catch (e) {
      debugPrint('Error reading from storage: $e');
      return null;
    }
  }

  @protected
  T readSync<T>(String key) {
    try {
      if (isWeb) {
        if (_prefs == null) return null as T;

        final value = _prefs!.get(_getKey(key));
        if (value == null) return null as T;

        // Handle primitive types
        if (T == String) return value as T;
        if (T == bool) return value as T;
        if (T == int) return value as T;
        if (T == double) return value as T;

        // Handle complex types (Map, List)
        if (value is String) {
          return json.decode(value) as T;
        }
        return value as T;
      }
      return box!.read(key);
    } catch (e) {
      debugPrint('Error reading from storage: $e');
      return null as T;
    }
  }

  @protected
  Future<void> write<T>(String key, T value) async {
    await ensureInitStorage();

    try {
      if (isWeb) {
        if (_prefs == null) return;

        if (value is String) {
          await _prefs!.setString(_getKey(key), value);
        } else if (value is bool) {
          await _prefs!.setBool(_getKey(key), value);
        } else if (value is int) {
          await _prefs!.setInt(_getKey(key), value);
        } else if (value is double) {
          await _prefs!.setDouble(_getKey(key), value);
        } else {
          await _prefs!.setString(_getKey(key), json.encode(value));
        }

        // Force flush for web to ensure data is written immediately
        await _prefs!.reload();
      } else {
        await box!.write(key, value);
      }
    } catch (e) {
      debugPrint('Error writing to storage: $e');
    }
  }

  @protected
  Future<void> delete(String key) async {
    await ensureInitStorage();

    try {
      if (isWeb) {
        if (_prefs == null) return;
        await _prefs!.remove(_getKey(key));
      } else {
        await box!.remove(key);
      }
    } catch (e) {
      debugPrint('Error deleting from storage: $e');
    }
  }

  @protected
  Future<void> erase() async {
    try {
      if (isWeb) {
        if (_prefs == null) return;
        final keys =
            _prefs!
                .getKeys()
                .where((key) => key.startsWith('$boxName:'))
                .toList();
        for (final key in keys) {
          await _prefs!.remove(key);
        }
      } else {
        await box!.erase();
      }
    } catch (e) {
      debugPrint('Error erasing storage: $e');
    }
  }

  // Add method to ensure storage is flushed
  @protected
  Future<void> flush() async {
    await ensureInitStorage();

    try {
      if (isWeb && _prefs != null) {
        await _prefs!.reload();
      }
      // For GetStorage, data is automatically flushed
    } catch (e) {
      debugPrint('Error flushing storage: $e');
    }
  }
}
