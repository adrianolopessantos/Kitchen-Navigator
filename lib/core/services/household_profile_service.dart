import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/household_profile.dart';

abstract final class HouseholdProfileService {
  static const storageKey =
      'kitchen_navigator_household_profile_v11';

  static Future<HouseholdProfile> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(storageKey);

    if (encoded == null || encoded.isEmpty) {
      return HouseholdProfile.initial();
    }

    try {
      return HouseholdProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(encoded) as Map),
      );
    } catch (_) {
      return HouseholdProfile.initial();
    }
  }

  static Future<void> save(HouseholdProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      storageKey,
      jsonEncode(profile.toJson()),
    );
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
