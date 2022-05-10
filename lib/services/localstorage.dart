import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences sharedPrefs;
  static String tokenKey = 'token';
  static String feedScrollPositionKey = 'feedScrollPosition';
  static String userProfileKey = 'userProfile';
  static String apiKeys = 'apiKeys';
  static String recentSearchesKey = 'recent_searches_key';

  static Future<bool> saveUserTokenSharedPref(String tokenVal) async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.setString(tokenKey, tokenVal);
  }

  static Future<String?> getUserTokenSharedPref() async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString(tokenKey);
  }

  static Future<bool> saveKeysSharedPref(String keys) async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.setString(apiKeys, keys);
  }

  static Future<String?> getKeysSharedPref() async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString(apiKeys);
  }

  static Future<bool> saveUserProfileSharedPref(String tokenVal) async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.setString(userProfileKey, tokenVal);
  }

  static Future<String?> getUserProfileSharedPref() async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString(userProfileKey);
  }

  static Future<bool> saveFeedScrollSharedPref(double scrollPosition) async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.setDouble(feedScrollPositionKey, scrollPosition);
  }

  static Future<double?> getFeedScrollSharedPref() async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getDouble(feedScrollPositionKey);
  }

  static Future<bool> clearSharedPrefKey(String key) async {
    sharedPrefs = await SharedPreferences.getInstance();
    return await sharedPrefs.remove(key);
  }

  static Future<bool> saveRecentSearchesSharedPref(
      String recentSearchesVal) async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.setString(recentSearchesKey, recentSearchesVal);
  }

  static Future<String?> getRecentSearchesSharedPref() async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString(recentSearchesKey);
  }
}
