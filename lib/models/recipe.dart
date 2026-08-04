class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.steps,
    this.servings = 2,
    this.description = '',
    this.category = 'Everyday',
    this.cuisine = 'International',
    this.difficulty = 'Easy',
    this.prepMinutes = 10,
    this.equipment = const [],
    this.temperatureCelsius,
    this.tags = const [],
  });

  final String id;
  final String name;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final int servings;

  final String description;
  final String category;
  final String cuisine;
  final String difficulty;
  final int prepMinutes;
  final List<String> equipment;
  final int? temperatureCelsius;
  final List<String> tags;

  int get totalSeconds =>
      steps.fold(0, (total, step) => total + step.seconds);

  int get cookMinutes => (totalSeconds / 60).ceil();

  int get totalMinutes => prepMinutes + cookMinutes;
}

class RecipeStep {
  const RecipeStep({
    required this.instruction,
    this.seconds = 0,
  });

  final String instruction;
  final int seconds;
}
