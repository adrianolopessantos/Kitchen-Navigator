import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/recipe.dart';
import '../../models/kitchen_appliance.dart';
import '../../core/state/app_scope.dart';
import '../../core/services/smart_recipe_service.dart';
import '../../core/services/voice_cooking_service.dart';

class CookingAssistantScreen extends StatefulWidget {
  const CookingAssistantScreen({
    super.key,
    required this.recipe,
    required this.servings,
  });

  final Recipe recipe;
  final int servings;

  @override
  State<CookingAssistantScreen> createState() =>
      _CookingAssistantScreenState();
}

class _CookingAssistantScreenState extends State<CookingAssistantScreen> {
  final Set<int> checkedIngredients = <int>{};
  int currentStep = 0;
  int remainingSeconds = 0;
  int originalSeconds = 0;
  bool timerRunning = false;
  bool cookingStarted = false;
  bool timerAutoStarted = false;
  int completedSteps = 0;
  Timer? timer;
  final VoiceCookingService voiceService = VoiceCookingService();
  bool voiceReady = false;
  bool voiceListening = false;
  bool readStepsAloud = true;
  String lastVoiceWords = '';
  KitchenAppliance? selectedAppliance;

  RecipeStep get step => widget.recipe.steps[currentStep];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeVoice();
    selectedAppliance ??=
        AppScope.of(context).kitchenAppliances.isEmpty
            ? null
            : AppScope.of(context).kitchenAppliances.first;
  }

  Future<void> _initializeVoice() async {
    if (voiceReady) return;
    final ready = await voiceService.initialize();
    if (!mounted) return;
    setState(() => voiceReady = ready);
  }

  Future<void> _speakCurrentStep() async {
    if (!readStepsAloud || !cookingStarted) return;
    await voiceService.speak(
      'Step ${currentStep + 1}. ${step.instruction}',
    );
  }

  Future<void> _listenForCommand() async {
    if (!voiceReady) await _initializeVoice();

    if (!voiceReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech recognition is unavailable on this device.',
          ),
        ),
      );
      return;
    }

    if (voiceListening) {
      await voiceService.stopListening();
      if (mounted) setState(() => voiceListening = false);
      return;
    }

    setState(() {
      voiceListening = true;
      lastVoiceWords = '';
    });

    await voiceService.listen(
      onWords: (words, finalResult) {
        if (!mounted) return;
        setState(() => lastVoiceWords = words);

        if (finalResult) {
          setState(() => voiceListening = false);
          _handleVoiceCommand(
            VoiceCookingService.parseCommand(words),
            words,
          );
        }
      },
    );
  }

  Future<void> _handleVoiceCommand(
    CookingVoiceCommand command,
    String words,
  ) async {
    switch (command) {
      case CookingVoiceCommand.next:
        nextStep();
        break;
      case CookingVoiceCommand.previous:
        previousStep();
        break;
      case CookingVoiceCommand.repeat:
        await _speakCurrentStep();
        break;
      case CookingVoiceCommand.startTimer:
        if (!timerRunning) toggleTimer();
        break;
      case CookingVoiceCommand.pauseTimer:
        if (timerRunning) toggleTimer();
        break;
      case CookingVoiceCommand.resetTimer:
        resetTimer();
        break;
      case CookingVoiceCommand.addMinute:
        addMinute();
        break;
      case CookingVoiceCommand.finish:
        await _finishRecipe();
        break;
      case CookingVoiceCommand.unknown:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              words.trim().isEmpty
                  ? 'No command heard.'
                  : 'Command not recognised: $words',
            ),
          ),
        );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    voiceService.dispose();
    super.dispose();
  }

  void startCooking() {
    setState(() {
      cookingStarted = true;
      currentStep = 0;
      completedSteps = 0;
      _loadStepTimer();
    });
    _speakCurrentStep();
  }

  void _loadStepTimer() {
    timer?.cancel();
    originalSeconds = step.seconds;
    remainingSeconds = step.seconds;
    timerRunning = false;
    timerAutoStarted = false;
  }

  void _startCurrentTimer({bool automatic = false}) {
    if (remainingSeconds <= 0 || timerRunning) return;

    setState(() {
      timerRunning = true;
      timerAutoStarted = automatic;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          remainingSeconds = 0;
          timerRunning = false;
        });
        _showTimerFinished();
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  void _autoStartCurrentStepTimer() {
    if (step.seconds <= 0) return;
    _startCurrentTimer(automatic: true);
  }

  void toggleTimer() {
    if (remainingSeconds <= 0 && originalSeconds > 0) {
      setState(() => remainingSeconds = originalSeconds);
    }

    if (timerRunning) {
      timer?.cancel();
      setState(() => timerRunning = false);
      return;
    }

    if (remainingSeconds <= 0) return;

    _startCurrentTimer();
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      remainingSeconds = originalSeconds;
      timerRunning = false;
      timerAutoStarted = false;
    });
  }

  void addMinute() {
    setState(() {
      remainingSeconds += 60;
      if (originalSeconds == 0) originalSeconds = remainingSeconds;
    });
  }

  Future<void> _showTimerFinished() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time is up'),
        content: Text('The timer for step ${currentStep + 1} has finished.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void previousStep() {
    if (currentStep == 0) return;
    timer?.cancel();
    setState(() {
      currentStep--;
      completedSteps = currentStep;
      _loadStepTimer();
    });
    _speakCurrentStep();
  }

  void nextStep() {
    if (currentStep >= widget.recipe.steps.length - 1) {
      _finishRecipe();
      return;
    }

    timer?.cancel();
    setState(() {
      completedSteps = (currentStep + 1).clamp(
        0,
        widget.recipe.steps.length,
      );
      currentStep++;
      _loadStepTimer();
    });
    _speakCurrentStep();
    _autoStartCurrentStepTimer();
  }

  Future<void> _finishRecipe() async {
    timer?.cancel();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Meal completed'),
        content: Text(
          '${widget.recipe.name} is ready. Great work!',
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check),
            label: const Text('Finish'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  String _formatIngredientQuantity(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.soup_kitchen_outlined,
              color: AppColors.cooking,
              size: 21,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.recipe.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (cookingStarted)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Text(
                  '${currentStep + 1}/${widget.recipe.steps.length}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: cookingStarted
            ? _buildCookingMode()
            : _buildPreparationMode(),
      ),
    );
  }

  Widget _buildPreparationMode() {
    final ready = checkedIngredients.length == widget.recipe.ingredients.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        const Text(
          'Before you start',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Check the ingredients you have ready.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                widget.recipe.ingredients.length,
                (index) {
                  final scaled = SmartRecipeService.scaleIngredients(
                    recipe: widget.recipe,
                    people: widget.servings,
                    pantryItems: AppScope.of(context).pantryItems,
                  );
                  final ingredient = scaled[index];
                  final checked = checkedIngredients.contains(index);

                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: checked,
                    title: Text(
                      ingredient.name,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        decoration:
                            checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      '${_formatIngredientQuantity(ingredient.quantity)} ${ingredient.unit}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          checkedIngredients.add(index);
                        } else {
                          checkedIngredients.remove(index);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.format_list_numbered,
                value: '${widget.recipe.steps.length}',
                label: 'Steps',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoTile(
                icon: Icons.schedule,
                value: '${(widget.recipe.totalSeconds / 60).ceil()} min',
                label: 'Estimated',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (AppScope.of(context).kitchenAppliances.isNotEmpty) ...[
          const Text(
            'Cooking appliance',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<KitchenAppliance>(
            initialValue: selectedAppliance,
            decoration: const InputDecoration(
              labelText: 'Use',
            ),
            items: AppScope.of(context)
                .kitchenAppliances
                .map(
                  (appliance) => DropdownMenuItem(
                    value: appliance,
                    child: Text(appliance.name),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => selectedAppliance = value),
          ),
          const SizedBox(height: 10),
          if (selectedAppliance != null)
            _ApplianceGuidanceCard(
              appliance: selectedAppliance!,
            ),
        ],
        const SizedBox(height: 14),
        Card(
          color: AppColors.surfaceElevated,
          child: SwitchListTile(
            value: readStepsAloud,
            onChanged: (value) =>
                setState(() => readStepsAloud = value),
            secondary: const Icon(
              Icons.record_voice_over_outlined,
              color: AppColors.primary,
            ),
            title: const Text('Read cooking steps aloud'),
            subtitle: Text(
              voiceReady
                  ? 'Voice commands are ready'
                  : 'Microphone initialises when cooking starts',
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: startCooking,
          icon: const Icon(Icons.play_arrow),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              ready ? 'Start Cooking' : 'Start Anyway',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCookingMode() {
    final hasTimer = originalSeconds > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 34),
      children: [
        Card(
          color: AppColors.cooking.withValues(alpha: .08),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.soup_kitchen_outlined,
                  color: AppColors.cooking,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cooking session · ${currentStep + 1}/${widget.recipe.steps.length}',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                Text(
                  '${((currentStep + 1) / widget.recipe.steps.length * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.cooking,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'STEP ${currentStep + 1}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (currentStep + 1) / widget.recipe.steps.length,
          minHeight: 8,
          borderRadius: BorderRadius.circular(999),
        ),
        const SizedBox(height: 26),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 30,
            ),
            child: Column(
              children: [
                Text(
                  step.instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 30,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (hasTimer) ...[
                  const SizedBox(height: 28),
                  Text(
                    formatTime(remainingSeconds),
                    style: TextStyle(
                      color: remainingSeconds == 0
                          ? AppColors.warning
                          : AppColors.primary,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (timerRunning && timerAutoStarted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cooking.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(
                          AppRadius.pill,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppColors.cooking,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Timer started automatically',
                            style: TextStyle(
                              color: AppColors.cooking,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: toggleTimer,
                          icon: Icon(
                            timerRunning
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              timerRunning ? 'Pause timer' : 'Start timer',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: resetTimer,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: addMinute,
                          icon: const Icon(Icons.add_alarm),
                          label: const Text('+1 minute'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 24),
                  const Icon(
                    Icons.touch_app_outlined,
                    size: 46,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete this step, then continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: AppColors.surfaceElevated,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _listenForCommand,
                        icon: Icon(
                          voiceListening
                              ? Icons.mic
                              : Icons.mic_none_outlined,
                        ),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          child: Text(
                            voiceListening
                                ? 'Listening…'
                                : 'Voice command',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    IconButton(
                      tooltip: 'Read step aloud',
                      onPressed: _speakCurrentStep,
                      icon: const Icon(Icons.volume_up_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  voiceListening
                      ? (lastVoiceWords.isEmpty
                          ? 'Say: next, repeat, start timer…'
                          : lastVoiceWords)
                      : 'Commands: next · previous · repeat · start timer · pause timer · reset timer · add minute',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: currentStep == 0 ? null : previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Previous'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: nextStep,
                icon: Icon(
                  currentStep == widget.recipe.steps.length - 1
                      ? Icons.check
                      : Icons.arrow_forward,
                ),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    currentStep == widget.recipe.steps.length - 1
                        ? 'Finish recipe'
                        : widget.recipe.steps[currentStep + 1].seconds > 0
                            ? 'Done — next + start timer'
                            : 'Done — next step',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (currentStep < widget.recipe.steps.length - 1)
          Card(
            color: AppColors.surfaceElevated,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.next_plan_outlined,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Next: ${widget.recipe.steps[currentStep + 1].instruction}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}


class _ApplianceGuidanceCard extends StatelessWidget {
  const _ApplianceGuidanceCard({
    required this.appliance,
  });

  final KitchenAppliance appliance;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final recommendation = _recommendationFor(appliance.type);
    final temperature = recommendation.$1 == null
        ? null
        : state.displayTemperature(recommendation.$1!);
    final unit = state.temperatureUnit.symbol;

    return Card(
      color: AppColors.surfaceElevated,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.thermostat_outlined,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                temperature == null
                    ? '${appliance.name}: ${recommendation.$2}'
                    : '${appliance.name}: $temperature$unit · '
                        '${recommendation.$2}'
                        '${appliance.preheatRequired ? ' · Preheat first' : ''}',
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (int?, String) _recommendationFor(ApplianceType type) {
    switch (type) {
      case ApplianceType.conventionalOven:
        return (200, 'Standard oven guidance');
      case ApplianceType.fanOven:
        return (180, 'Reduce standard oven temperature');
      case ApplianceType.airFryer:
        return (175, 'Check food about 25% earlier');
      case ApplianceType.toasterOven:
        return (185, 'Use the centre rack');
      case ApplianceType.grill:
        return (220, 'Watch closely while grilling');
      case ApplianceType.slowCooker:
        return (90, 'Use low setting for long cooking');
      case ApplianceType.sousVide:
        return (65, 'Set water bath accurately');
      case ApplianceType.pressureCooker:
        return (null, 'Use pressure programme and recipe timing');
      case ApplianceType.microwave:
        return (null, 'Use ${type.label.toLowerCase()} power and short intervals');
      case ApplianceType.stovetop:
        return (null, 'Use medium heat unless the step says otherwise');
      case ApplianceType.riceCooker:
        return (null, 'Use the normal cooking programme');
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> openCookingAssistant(
  BuildContext context,
  Recipe recipe, {
  int? servings,
}) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => CookingAssistantScreen(
        recipe: recipe,
        servings: servings ?? recipe.servings,
      ),
    ),
  );
}


class MultiMealCookingAssistantScreen extends StatefulWidget {
  const MultiMealCookingAssistantScreen({
    super.key,
    required this.recipes,
  });

  final List<Recipe> recipes;

  @override
  State<MultiMealCookingAssistantScreen> createState() =>
      _MultiMealCookingAssistantScreenState();
}

class _MealCookingState {
  _MealCookingState(this.recipe)
      : remainingSeconds =
            recipe.steps.isEmpty ? 0 : recipe.steps.first.seconds;

  final Recipe recipe;
  int stepIndex = 0;
  int remainingSeconds;
  bool timerRunning = false;
  bool finished = false;

  RecipeStep? get step =>
      recipe.steps.isEmpty || finished ? null : recipe.steps[stepIndex];
}

class _MultiMealCookingAssistantScreenState
    extends State<MultiMealCookingAssistantScreen> {
  late final List<_MealCookingState> meals;
  Timer? ticker;
  final VoiceCookingService multiMealVoiceService =
      VoiceCookingService();
  bool soundAlerts = true;
  bool spokenGuidance = true;
  String? lastFocusMealId;

  @override
  void initState() {
    super.initState();
    meals = widget.recipes
        .take(4)
        .map(_MealCookingState.new)
        .toList();
    multiMealVoiceService.initialize();
    ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceFocusIfChanged();
    });
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    var changed = false;
    final finishedTimers = <_MealCookingState>[];

    for (final meal in meals) {
      if (!meal.timerRunning || meal.remainingSeconds <= 0) continue;
      meal.remainingSeconds--;
      changed = true;
      if (meal.remainingSeconds <= 0) {
        meal.timerRunning = false;
        finishedTimers.add(meal);
      }
    }

    if (changed) {
      setState(() {});
      for (final meal in finishedTimers) {
        _announceTimerFinished(meal);
      }
      _announceFocusIfChanged();
    }
  }

  Future<void> _announceTimerFinished(
    _MealCookingState meal,
  ) async {
    if (!soundAlerts) return;

    await multiMealVoiceService.speak(
      '${meal.recipe.name} timer finished.',
    );
  }

  Future<void> _announceFocusIfChanged() async {
    if (!spokenGuidance) return;
    final focus = nextMeal;
    if (focus == null || focus.recipe.id == lastFocusMealId) return;

    lastFocusMealId = focus.recipe.id;
    final instruction = focus.step?.instruction ?? '';
    await multiMealVoiceService.speak(
      'Focus now. ${focus.recipe.name}. $instruction',
    );
  }

  Future<void> _repeatFocus() async {
    final focus = nextMeal;
    if (focus == null) return;
    final instruction = focus.step?.instruction ?? '';
    await multiMealVoiceService.speak(
      '${focus.recipe.name}. $instruction',
    );
  }

  void _next(_MealCookingState meal) {
    if (meal.finished) return;

    if (meal.stepIndex >= meal.recipe.steps.length - 1) {
      setState(() {
        meal.finished = true;
        meal.timerRunning = false;
        meal.remainingSeconds = 0;
      });
      if (soundAlerts) {
        multiMealVoiceService.speak(
          '${meal.recipe.name} is complete.',
        );
      }
      _announceFocusIfChanged();
      return;
    }

    setState(() {
      meal.stepIndex++;
      meal.remainingSeconds = meal.step?.seconds ?? 0;
      meal.timerRunning = meal.remainingSeconds > 0;
    });
    _announceFocusIfChanged();
  }

  void _toggleTimer(_MealCookingState meal) {
    if (meal.remainingSeconds <= 0) return;
    setState(() => meal.timerRunning = !meal.timerRunning);
  }

  _MealCookingState? get nextMeal {
    final active = meals.where((meal) => !meal.finished).toList();
    if (active.isEmpty) return null;

    active.sort((a, b) {
      final aPriority = a.timerRunning
          ? a.remainingSeconds
          : (a.remainingSeconds > 0 ? a.remainingSeconds + 100000 : 0);
      final bPriority = b.timerRunning
          ? b.remainingSeconds
          : (b.remainingSeconds > 0 ? b.remainingSeconds + 100000 : 0);
      return aPriority.compareTo(bPriority);
    });
    return active.first;
  }

  String _time(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final focus = nextMeal;
    final finished = meals.where((meal) => meal.finished).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cook Together'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Card(
              color: AppColors.cooking.withValues(alpha: .10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.soup_kitchen_outlined,
                      color: AppColors.cooking,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            focus == null
                                ? 'All meals complete'
                                : 'Focus now · ${focus.recipe.name}',
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            focus == null
                                ? 'Everything is ready.'
                                : focus.step?.instruction ?? '',
                            style: const TextStyle(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$finished/${meals.length}',
                      style: const TextStyle(
                        color: AppColors.cooking,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilterChip(
                      selected: soundAlerts,
                      onSelected: (value) =>
                          setState(() => soundAlerts = value),
                      avatar: Icon(
                        soundAlerts
                            ? Icons.volume_up_outlined
                            : Icons.volume_off_outlined,
                        size: 17,
                      ),
                      label: const Text('Timer alerts'),
                    ),
                    FilterChip(
                      selected: spokenGuidance,
                      onSelected: (value) {
                        setState(() => spokenGuidance = value);
                        if (value) {
                          lastFocusMealId = null;
                          _announceFocusIfChanged();
                        }
                      },
                      avatar: Icon(
                        spokenGuidance
                            ? Icons.record_voice_over_outlined
                            : Icons.voice_over_off_outlined,
                        size: 17,
                      ),
                      label: const Text('Voice guidance'),
                    ),
                    TextButton.icon(
                      onPressed: _repeatFocus,
                      icon: const Icon(Icons.replay, size: 17),
                      label: const Text('Repeat focus'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            for (final meal in meals) ...[
              _MultiMealCard(
                meal: meal,
                formatTime: _time,
                onNext: () => _next(meal),
                onToggleTimer: () => _toggleTimer(meal),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _MultiMealCard extends StatelessWidget {
  const _MultiMealCard({
    required this.meal,
    required this.formatTime,
    required this.onNext,
    required this.onToggleTimer,
  });

  final _MealCookingState meal;
  final String Function(int) formatTime;
  final VoidCallback onNext;
  final VoidCallback onToggleTimer;

  @override
  Widget build(BuildContext context) {
    final step = meal.step;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meal.recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (!meal.finished)
                  Text(
                    '${meal.stepIndex + 1}/${meal.recipe.steps.length}',
                    style: const TextStyle(
                      color: AppColors.cooking,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (meal.finished)
              const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: 7),
                  Text(
                    'Meal complete',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            else ...[
              Text(
                step?.instruction ?? '',
                style: const TextStyle(color: AppColors.text),
              ),
              if ((step?.seconds ?? 0) > 0) ...[
                const SizedBox(height: 10),
                if (meal.remainingSeconds == 0 &&
                    !meal.timerRunning)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: .12),
                      borderRadius:
                          BorderRadius.circular(AppRadius.medium),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          color: AppColors.warning,
                          size: 18,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Timer finished · action needed',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Text(
                      formatTime(meal.remainingSeconds),
                      style: const TextStyle(
                        color: AppColors.cooking,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton.filledTonal(
                      tooltip:
                          meal.timerRunning ? 'Pause timer' : 'Start timer',
                      onPressed: onToggleTimer,
                      icon: Icon(
                        meal.timerRunning
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onNext,
                  icon: Icon(
                    meal.stepIndex >= meal.recipe.steps.length - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    meal.stepIndex >= meal.recipe.steps.length - 1
                        ? 'Finish meal'
                        : (meal.recipe.steps[meal.stepIndex + 1].seconds > 0
                            ? 'Done · next + start timer'
                            : 'Done · next step'),
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

Future<bool?> openMultiMealCookingAssistant(
  BuildContext context,
  List<Recipe> recipes,
) {
  final selected = recipes.take(4).toList();
  if (selected.length < 2) return Future<bool?>.value(false);

  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => MultiMealCookingAssistantScreen(
        recipes: selected,
      ),
    ),
  );
}
