import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../models/nutrition_summary.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final household = state.todaysNutrition;
    final members = state.todaysFamilyNutritionEstimates;
    final available = state.hasTodaysNutrition;

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition intelligence')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            const Text(
              'Today’s planned nutrition',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${state.householdProfile.householdName} · '
              '${state.householdPeople} people',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            if (!available)
              const _PendingCard()
            else ...[
              _HouseholdNutritionCard(summary: household),
              const SizedBox(height: 18),
              const Text(
                'INDIVIDUAL ESTIMATES',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 8),
              if (members.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Add family members to split household nutrition estimates.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                )
              else
                ...members.map(
                  (member) => _MemberNutritionCard(
                    estimate: member,
                  ),
                ),
              const SizedBox(height: 18),
              Card(
                color: AppColors.surfaceElevated,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'All values are estimates derived from planned recipes and simple foods. Individual portions are allocated using age-based serving weights. They are not medical advice.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(
              Icons.monitor_heart_outlined,
              color: AppColors.primary,
              size: 44,
            ),
            const SizedBox(height: 12),
            const Text(
              'Nutrition analysis pending',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Plan meals for today to create household and individual nutrition estimates.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _HouseholdNutritionCard extends StatelessWidget {
  const _HouseholdNutritionCard({required this.summary});

  final NutritionSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.groups_outlined,
                  color: AppColors.primary,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Whole household · Estimated',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '${summary.calories.round()} kcal',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '${summary.mealCount} planned meal${summary.mealCount == 1 ? '' : 's'} · '
              '${summary.varietyScore}% variety',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Protein',
                    value: '${summary.protein.round()} g',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Carbs',
                    value:
                        '${summary.carbohydrates.round()} g',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Fat',
                    value: '${summary.fat.round()} g',
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

class _MemberNutritionCard extends StatelessWidget {
  const _MemberNutritionCard({required this.estimate});

  final FamilyMemberNutritionEstimate estimate;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        estimate.memberName,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${(estimate.share * 100).round()}% estimated serving share',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${estimate.calories.round()} kcal',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Protein',
                    value: '${estimate.protein.round()} g',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Carbs',
                    value:
                        '${estimate.carbohydrates.round()} g',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Fat',
                    value: '${estimate.fat.round()} g',
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

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

Future<void> openNutritionCenter(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => const NutritionScreen(),
    ),
  );
}
