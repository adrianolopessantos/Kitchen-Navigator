import 'package:flutter/material.dart';
import '../../core/services/ai_kitchen_service.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../cooking/cooking_assistant_screen.dart';

class AiKitchenScreen extends StatefulWidget {
  const AiKitchenScreen({super.key});

  @override
  State<AiKitchenScreen> createState() => _AiKitchenScreenState();
}

class _AiKitchenScreenState extends State<AiKitchenScreen> {
  int people = 2;
  double maxMinutes = 40;
  bool useExpiringFirst = true;
  bool vegetarianOnly = false;
  bool loading = false;
  List<AiMealSuggestion> suggestions = const [];

  Future<void> generateSuggestions() async {
    final state = AppScope.of(context);

    setState(() {
      loading = true;
      suggestions = const [];
    });

    final results = await AiKitchenService.generate(
      AiKitchenRequest(
        people: people,
        maxMinutes: maxMinutes.round(),
        useExpiringFirst: useExpiringFirst,
        vegetarianOnly: vegetarianOnly,
        pantryItems: state.pantryItems,
        recipes: state.recipes,
      ),
    );

    if (!mounted) return;
    setState(() {
      suggestions = results;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Kitchen Preview')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            const Text(
              'What should we cook?',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'This preview works locally. It does not use an external AI account or send kitchen data online.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'People',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: List.generate(8, (index) {
                        final value = index + 1;
                        return ChoiceChip(
                          selected: people == value,
                          onSelected: (_) => setState(() => people = value),
                          label: Text('$value'),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Maximum cooking time: ${maxMinutes.round()} minutes',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Slider(
                      value: maxMinutes,
                      min: 10,
                      max: 90,
                      divisions: 16,
                      label: '${maxMinutes.round()} min',
                      onChanged: (value) =>
                          setState(() => maxMinutes = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: useExpiringFirst,
                      onChanged: (value) =>
                          setState(() => useExpiringFirst = value),
                      title: const Text('Use expiring ingredients first'),
                      subtitle: Text(
                        '${state.expiringSoonCount + state.expiredCount} urgent pantry item${state.expiringSoonCount + state.expiredCount == 1 ? '' : 's'}',
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: vegetarianOnly,
                      onChanged: (value) =>
                          setState(() => vegetarianOnly = value),
                      title: const Text('Vegetarian meals only'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: loading ? null : generateSuggestions,
                        icon: loading
                            ? const SizedBox.square(
                                dimension: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            loading
                                ? 'Creating suggestions'
                                : 'Generate meal suggestions',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (suggestions.isEmpty && !loading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Choose your preferences and generate suggestions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              ...List.generate(suggestions.length, (index) {
                return _SuggestionCard(
                  rank: index + 1,
                  suggestion: suggestions[index],
                  people: people,
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.rank,
    required this.suggestion,
    required this.people,
  });

  final int rank;
  final AiMealSuggestion suggestion;
  final int people;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF243321),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    suggestion.recipe.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (suggestion.expiringMatches.isNotEmpty)
                  const Icon(
                    Icons.eco_outlined,
                    color: AppColors.warning,
                  ),
              ],
            ),
            const SizedBox(height: 11),
            ...suggestion.reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (suggestion.missingIngredients.isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(
                'Missing: ${suggestion.missingIngredients.join(', ')}',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ] else ...[
              const SizedBox(height: 7),
              const Text(
                'All ingredients appear to be available.',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final state = AppScope.of(context);
                      final day = state.todayName;
                      if (!state.containsRecipe(day, suggestion.recipe.id)) {
                        state.toggleRecipe(day, suggestion.recipe);
                      }
                      state.setPeople(day, suggestion.recipe.id, people);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${suggestion.recipe.name} added to $day.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Add to today'),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        openCookingAssistant(context, suggestion.recipe),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Cook'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openAiKitchen(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const AiKitchenScreen()),
  );
}
