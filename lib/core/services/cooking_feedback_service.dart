import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cooking_feedback.dart';

abstract final class CookingFeedbackService {
  static const storageKey =
      'kitchen_navigator_cooking_feedback_v11';

  static Future<List<CookingFeedback>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(storageKey);
    if (encoded == null || encoded.isEmpty) return [];

    try {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .map(
            (value) => CookingFeedback.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> add(CookingFeedback feedback) async {
    final values = await load();
    values.add(feedback);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      storageKey,
      jsonEncode(values.map((value) => value.toJson()).toList()),
    );
  }

  static Future<List<CookingFeedback>> forRecipe(
    String recipeId,
  ) async {
    final values = await load();
    return values
        .where((value) => value.recipeId == recipeId)
        .toList();
  }
}
