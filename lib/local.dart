import 'package:shared_preferences/shared_preferences.dart';

class MyLocalStorage {
  MyLocalStorage._();
  static SharedPreferences? sharedPreferences;
  static const String tokenKey = "key";

  /// Initialize SharedPreferences
  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  /// Save Data (String, int, bool, double, List<String>)
  static Future<bool> setData(String key, dynamic value) async {
    if (sharedPreferences == null) return false;

    if (value is String) {
      return await sharedPreferences!.setString(key, value);
    } else if (value is int) {
      return await sharedPreferences!.setInt(key, value);
    } else if (value is bool) {
      return await sharedPreferences!.setBool(key, value);
    } else if (value is double) {
      return await sharedPreferences!.setDouble(key, value);
    } else if (value is List<String>) {
      return await sharedPreferences!.setStringList(key, value);
    } else {
      throw Exception("Invalid data type");
    }
  }

  /// Get Data
  static dynamic getData(String key) async {
    if (sharedPreferences == null) return null;
    return sharedPreferences!.get(key) ?? '';
  }

  /// Update Data (Same as setData but ensures key exists)
  static Future<bool> updateData(String key, dynamic value) async {
    if (sharedPreferences == null || !sharedPreferences!.containsKey(key)) {
      return false;
    }
    return await setData(key, value);
  }

  /// Remove Data by Key
  static Future<bool> removeData(String key) async {
    if (sharedPreferences == null) return false;
    return await sharedPreferences!.remove(key);
  }

  /// Clear All Data
  static Future<bool> clearAllData() async {
    if (sharedPreferences == null) return false;
    return await sharedPreferences!.clear();
  }
}
