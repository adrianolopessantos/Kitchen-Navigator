import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/cooking_feedback_service.dart';
import 'package:kitchen_navigator/models/cooking_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Cooking feedback persists as kitchen memory', () async {
    SharedPreferences.setMockInitialValues({});

    await CookingFeedbackService.add(
      CookingFeedback(
        id: '1',
        recipeId: 'R0001',
        recipeName: 'Family Pasta',
        rating: 5,
        createdAt: DateTime(2026, 8, 5),
        notes: 'Children preferred less chilli.',
      ),
    );

    final values =
        await CookingFeedbackService.forRecipe('R0001');

    expect(values.single.rating, 5);
    expect(values.single.notes, contains('less chilli'));
  });
}
