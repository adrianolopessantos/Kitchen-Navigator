import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../models/household_profile.dart';

class HouseholdSetupScreen extends StatefulWidget {
  const HouseholdSetupScreen({
    super.key,
    this.editing = false,
  });

  final bool editing;

  @override
  State<HouseholdSetupScreen> createState() =>
      _HouseholdSetupScreenState();
}

class _HouseholdSetupScreenState
    extends State<HouseholdSetupScreen> {
  final pageController = PageController();
  final householdNameController = TextEditingController();
  final budgetController = TextEditingController();
  final cuisineController = TextEditingController();
  final members = <FamilyMember>[];

  int step = 0;
  int mealsPerDay = 3;
  int snacksPerDay = 1;
  int maxCookingMinutes = 30;
  bool usePantryFirst = true;
  bool useLeftovers = true;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;

    final profile = AppScope.of(context).householdProfile;
    householdNameController.text = profile.householdName;
    budgetController.text =
        profile.monthlyBudget.toStringAsFixed(0);
    cuisineController.text =
        profile.preferredCuisines.join(', ');
    members.addAll(profile.members);
    mealsPerDay = profile.mealsPerDay;
    snacksPerDay = profile.snacksPerDay;
    maxCookingMinutes = profile.maxWeekdayCookingMinutes;
    usePantryFirst = profile.usePantryFirst;
    useLeftovers = profile.useLeftovers;
    initialized = true;
  }

  @override
  void dispose() {
    pageController.dispose();
    householdNameController.dispose();
    budgetController.dispose();
    cuisineController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (step == 0 &&
        householdNameController.text.trim().isEmpty) {
      _message('Enter a household name.');
      return;
    }

    if (step == 1 && members.isEmpty) {
      _message('Add at least one family member.');
      return;
    }

    if (step < 3) {
      setState(() => step++);
      await pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
      return;
    }

    await _save();
  }

  Future<void> _back() async {
    if (step == 0) {
      if (widget.editing && mounted) Navigator.pop(context);
      return;
    }

    setState(() => step--);
    await pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _save() async {
    final state = AppScope.of(context);
    final budget = double.tryParse(
          budgetController.text.replaceAll(',', '.'),
        ) ??
        500;

    final cuisines = cuisineController.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    final profile = HouseholdProfile(
      householdName: householdNameController.text.trim(),
      members: List.unmodifiable(members),
      mealsPerDay: mealsPerDay,
      snacksPerDay: snacksPerDay,
      monthlyBudget: budget.clamp(0, 100000),
      preferredCuisines:
          cuisines.isEmpty ? const ['Mediterranean'] : cuisines,
      maxWeekdayCookingMinutes: maxCookingMinutes,
      usePantryFirst: usePantryFirst,
      useLeftovers: useLeftovers,
      setupComplete: true,
    );

    await state.saveHouseholdProfile(profile);
    if (!mounted) return;

    if (widget.editing) {
      Navigator.pop(context);
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  Future<void> _addMember() async {
    final member = await showModalBottomSheet<FamilyMember>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const _FamilyMemberEditor(),
    );

    if (member != null) {
      setState(() => members.add(member));
    }
  }

  Future<void> _editMember(int index) async {
    final member = await showModalBottomSheet<FamilyMember>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => _FamilyMemberEditor(
        existing: members[index],
      ),
    );

    if (member != null) {
      setState(() => members[index] = member);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.editing
          ? AppBar(title: const Text('Household profile'))
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.editing)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.explore_outlined,
                      color: AppColors.primary,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Kitchen Navigator',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.editing
                        ? 'Update your household'
                        : 'Tell us about your family',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Step ${step + 1} of 4 · '
                    '${_stepTitle(step)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (step + 1) / 4,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _householdStep(),
                  _familyStep(),
                  _mealStep(),
                  _planningStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
              child: Row(
                children: [
                  if (step > 0 || widget.editing)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _back,
                        child: Text(
                          step == 0 ? 'Cancel' : 'Back',
                        ),
                      ),
                    ),
                  if (step > 0 || widget.editing)
                    const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(
                        step == 3 ? 'Save household' : 'Continue',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _householdStep() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _WizardIcon(icon: Icons.home_outlined),
        const SizedBox(height: 20),
        TextField(
          controller: householdNameController,
          decoration: const InputDecoration(
            labelText: 'Household name',
            hintText: 'Lopes Family Kitchen',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: budgetController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Monthly food budget',
            prefixText: '€ ',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: cuisineController,
          decoration: const InputDecoration(
            labelText: 'Preferred cuisines',
            hintText: 'Mediterranean, Italian, Portuguese',
            helperText: 'Separate cuisines with commas',
          ),
        ),
      ],
    );
  }

  Widget _familyStep() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Family members',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: _addMember,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (members.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(22),
              child: Column(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    color: AppColors.primary,
                    size: 42,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Add the people you plan meals for.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(members.length, (index) {
            final member = members[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    member.type == FamilyMemberType.child
                        ? Icons.child_care
                        : Icons.person_outline,
                  ),
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  '${member.age} years · '
                  '${member.dietaryPreferences.isEmpty ? 'No special diet' : member.dietaryPreferences.map((item) => item.label).join(', ')}'
                  '${member.allergies.isEmpty ? '' : ' · Allergies: ${member.allergies.join(', ')}'}',
                ),
                onTap: () => _editMember(index),
                trailing: IconButton(
                  tooltip: 'Remove',
                  onPressed: () =>
                      setState(() => members.removeAt(index)),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _mealStep() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _WizardIcon(icon: Icons.restaurant_menu),
        const SizedBox(height: 20),
        _CounterCard(
          title: 'Main meals each day',
          subtitle: 'Breakfast, lunch, dinner, or your own routine',
          value: mealsPerDay,
          minimum: 1,
          maximum: 6,
          onChanged: (value) =>
              setState(() => mealsPerDay = value),
        ),
        const SizedBox(height: 12),
        _CounterCard(
          title: 'Snacks each day',
          subtitle: 'Fruit, yogurt, toast, nuts, and simple options',
          value: snacksPerDay,
          minimum: 0,
          maximum: 4,
          onChanged: (value) =>
              setState(() => snacksPerDay = value),
        ),
        const SizedBox(height: 12),
        _CounterCard(
          title: 'Maximum weekday cooking time',
          subtitle: 'Used when creating monthly suggestions',
          value: maxCookingMinutes,
          minimum: 10,
          maximum: 120,
          step: 5,
          suffix: ' min',
          onChanged: (value) =>
              setState(() => maxCookingMinutes = value),
        ),
      ],
    );
  }

  Widget _planningStep() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _WizardIcon(icon: Icons.auto_awesome),
        const SizedBox(height: 20),
        SwitchListTile(
          value: usePantryFirst,
          onChanged: (value) =>
              setState(() => usePantryFirst = value),
          title: const Text('Use pantry products first'),
          subtitle: const Text(
            'Prefer products already available or expiring soon.',
          ),
          secondary: const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primary,
          ),
        ),
        const Divider(),
        SwitchListTile(
          value: useLeftovers,
          onChanged: (value) =>
              setState(() => useLeftovers = value),
          title: const Text('Plan useful leftovers'),
          subtitle: const Text(
            'Reuse cooked food in practical meals to reduce waste.',
          ),
          secondary: const Icon(
            Icons.recycling_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppColors.surfaceElevated,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              '${members.length} people · $mealsPerDay meals · '
              '$snacksPerDay snacks · '
              '€${budgetController.text.trim().isEmpty ? '500' : budgetController.text.trim()} per month',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _stepTitle(int value) {
    switch (value) {
      case 0:
        return 'Household';
      case 1:
        return 'Family';
      case 2:
        return 'Daily meals';
      default:
        return 'Planning style';
    }
  }
}

class _FamilyMemberEditor extends StatefulWidget {
  const _FamilyMemberEditor({this.existing});

  final FamilyMember? existing;

  @override
  State<_FamilyMemberEditor> createState() =>
      _FamilyMemberEditorState();
}

class _FamilyMemberEditorState
    extends State<_FamilyMemberEditor> {
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  late final TextEditingController allergiesController;
  late final TextEditingController likesController;
  late final TextEditingController dislikesController;

  FamilyMemberType type = FamilyMemberType.adult;
  final selectedDiets = <DietaryPreference>{};

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    nameController =
        TextEditingController(text: existing?.name ?? '');
    ageController = TextEditingController(
      text: existing?.age.toString() ?? '30',
    );
    allergiesController = TextEditingController(
      text: existing?.allergies.join(', ') ?? '',
    );
    likesController = TextEditingController(
      text: existing?.likes.join(', ') ?? '',
    );
    dislikesController = TextEditingController(
      text: existing?.dislikes.join(', ') ?? '',
    );
    type = existing?.type ?? FamilyMemberType.adult;
    selectedDiets.addAll(
      existing?.dietaryPreferences ?? const [],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    allergiesController.dispose();
    likesController.dispose();
    dislikesController.dispose();
    super.dispose();
  }

  List<String> _list(TextEditingController controller) {
    return controller.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  void _save() {
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text);

    if (name.isEmpty || age == null || age < 0 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid name and age.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      FamilyMember(
        id: widget.existing?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        type: type,
        age: age,
        dietaryPreferences: selectedDiets.toList(),
        allergies: _list(allergiesController),
        likes: _list(likesController),
        dislikes: _list(dislikesController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 22,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null
                  ? 'Add family member'
                  : 'Edit family member',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            SegmentedButton<FamilyMemberType>(
              segments: const [
                ButtonSegment(
                  value: FamilyMemberType.adult,
                  icon: Icon(Icons.person_outline),
                  label: Text('Adult'),
                ),
                ButtonSegment(
                  value: FamilyMemberType.child,
                  icon: Icon(Icons.child_care),
                  label: Text('Child'),
                ),
              ],
              selected: {type},
              onSelectionChanged: (values) =>
                  setState(() => type = values.first),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dietary preferences',
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: DietaryPreference.values
                  .where((value) => value != DietaryPreference.none)
                  .map(
                    (value) => FilterChip(
                      selected: selectedDiets.contains(value),
                      label: Text(value.label),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          selectedDiets.add(value);
                        } else {
                          selectedDiets.remove(value);
                        }
                      }),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: allergiesController,
              decoration: const InputDecoration(
                labelText: 'Allergies',
                hintText: 'Peanuts, shellfish',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: likesController,
              decoration: const InputDecoration(
                labelText: 'Likes',
                hintText: 'Chicken, fruit, yogurt',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dislikesController,
              decoration: const InputDecoration(
                labelText: 'Dislikes',
                hintText: 'Mushrooms, spicy food',
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save family member'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WizardIcon extends StatelessWidget {
  const _WizardIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, color: AppColors.primary, size: 36),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
    this.step = 1,
    this.suffix = '',
  });

  final String title;
  final String subtitle;
  final int value;
  final int minimum;
  final int maximum;
  final int step;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: value <= minimum
                  ? null
                  : () => onChanged(value - step),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '$value$suffix',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            IconButton(
              onPressed: value >= maximum
                  ? null
                  : () => onChanged(value + step),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openHouseholdSetup(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => const HouseholdSetupScreen(editing: true),
    ),
  );
}
