import 'package:flutter/material.dart';
import '../../core/services/cooking_feedback_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/cooking_feedback.dart';
import '../../models/recipe.dart';

class CookingFeedbackScreen extends StatefulWidget {
  const CookingFeedbackScreen({
    super.key,
    required this.recipe,
  });

  final Recipe recipe;

  @override
  State<CookingFeedbackScreen> createState() =>
      _CookingFeedbackScreenState();
}

class _CookingFeedbackScreenState
    extends State<CookingFeedbackScreen> {
  int rating = 4;
  bool everyoneLikedIt = true;
  bool tooSpicy = false;
  bool tooSalty = false;
  String portions = 'right';
  final notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await CookingFeedbackService.add(
      CookingFeedback(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        recipeId: widget.recipe.id,
        recipeName: widget.recipe.name,
        rating: rating,
        createdAt: DateTime.now(),
        everyoneLikedIt: everyoneLikedIt,
        tooSpicy: tooSpicy,
        tooSalty: tooSalty,
        portionFeedback: portions,
        notes: notesController.text.trim(),
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How was the meal?')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            widget.recipe.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => setState(() => rating = index + 1),
                iconSize: 36,
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: AppColors.warning,
                ),
              ),
            ),
          ),
          SwitchListTile(
            value: everyoneLikedIt,
            onChanged: (value) =>
                setState(() => everyoneLikedIt = value),
            title: const Text('Everyone liked it'),
          ),
          CheckboxListTile(
            value: tooSpicy,
            onChanged: (value) =>
                setState(() => tooSpicy = value ?? false),
            title: const Text('Too spicy'),
          ),
          CheckboxListTile(
            value: tooSalty,
            onChanged: (value) =>
                setState(() => tooSalty = value ?? false),
            title: const Text('Too salty'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: portions,
            decoration: const InputDecoration(
              labelText: 'Portion size',
            ),
            items: const [
              DropdownMenuItem(
                value: 'small',
                child: Text('Too little food'),
              ),
              DropdownMenuItem(
                value: 'right',
                child: Text('Portions were right'),
              ),
              DropdownMenuItem(
                value: 'large',
                child: Text('Too much food'),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => portions = value);
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: notesController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Kitchen memory notes',
              hintText:
                  'Use less salt, cook longer, children preferred it without mushrooms…',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save meal feedback'),
          ),
        ],
      ),
    );
  }
}

Future<bool?> openCookingFeedback(
  BuildContext context,
  Recipe recipe,
) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => CookingFeedbackScreen(recipe: recipe),
    ),
  );
}
