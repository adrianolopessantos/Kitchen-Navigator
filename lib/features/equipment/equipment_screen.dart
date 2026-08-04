import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../models/kitchen_appliance.dart';

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen Equipment')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add appliance'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            const Text(
              'Your cooking devices',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Kitchen Navigator will adapt cooking time and temperature to the appliances you own.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            SegmentedButton<TemperatureUnit>(
              segments: const [
                ButtonSegment(
                  value: TemperatureUnit.celsius,
                  label: Text('Celsius'),
                ),
                ButtonSegment(
                  value: TemperatureUnit.fahrenheit,
                  label: Text('Fahrenheit'),
                ),
              ],
              selected: {state.temperatureUnit},
              onSelectionChanged: (values) =>
                  state.setTemperatureUnit(values.first),
            ),
            const SizedBox(height: 16),
            if (state.kitchenAppliances.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(22),
                  child: Text(
                    'No appliances added yet.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              ...state.kitchenAppliances.map(
                (appliance) => _ApplianceCard(
                  appliance: appliance,
                  onEdit: () =>
                      _showEditor(context, existing: appliance),
                  onDelete: () => _delete(context, appliance),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showEditor(
    BuildContext context, {
    KitchenAppliance? existing,
  }) async {
    final state = AppScope.of(context);
    var type = existing?.type ?? ApplianceType.airFryer;
    final nameController = TextEditingController(
      text: existing?.name ?? type.defaultName,
    );
    final minController = TextEditingController(
      text: '${existing?.minCelsius ?? type.defaultMinCelsius}',
    );
    final maxController = TextEditingController(
      text: '${existing?.maxCelsius ?? type.defaultMaxCelsius}',
    );
    final capacityController = TextEditingController(
      text: existing?.capacityLitres?.toString() ?? '',
    );
    final powerController = TextEditingController(
      text: existing?.powerWatts?.toString() ?? '',
    );
    var preheat = existing?.preheatRequired ?? type.usuallyPreheats;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                18,
                16,
                MediaQuery.viewInsetsOf(context).bottom + 22,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existing == null ? 'Add appliance' : 'Edit appliance',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<ApplianceType>(
                      initialValue: type,
                      decoration: const InputDecoration(
                        labelText: 'Appliance type',
                      ),
                      items: ApplianceType.values.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        );
                      }).toList(),
                      onChanged: existing != null
                          ? null
                          : (value) {
                              if (value == null) return;
                              setModalState(() {
                                type = value;
                                nameController.text = value.defaultName;
                                minController.text =
                                    '${value.defaultMinCelsius}';
                                maxController.text =
                                    '${value.defaultMaxCelsius}';
                                preheat = value.usuallyPreheats;
                              });
                            },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Custom name',
                      ),
                    ),
                    if (type.supportsTemperature) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Minimum °C',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: maxController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Maximum °C',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: capacityController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Capacity in litres',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: powerController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Power in watts',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: preheat,
                      onChanged: (value) =>
                          setModalState(() => preheat = value),
                      title: const Text('Preheating required'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final min = int.tryParse(minController.text) ??
                              type.defaultMinCelsius;
                          final max = int.tryParse(maxController.text) ??
                              type.defaultMaxCelsius;

                          if (name.isEmpty || max < min) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enter a name and valid temperature range.',
                                ),
                              ),
                            );
                            return;
                          }

                          final appliance = KitchenAppliance(
                            id: existing?.id ??
                                DateTime.now()
                                    .microsecondsSinceEpoch
                                    .toString(),
                            type: type,
                            name: name,
                            minCelsius: min,
                            maxCelsius: max,
                            preheatRequired: preheat,
                            capacityLitres: double.tryParse(
                              capacityController.text,
                            ),
                            powerWatts: int.tryParse(
                              powerController.text,
                            ),
                          );

                          if (existing == null) {
                            state.addAppliance(appliance);
                          } else {
                            state.updateAppliance(appliance);
                          }

                          Navigator.pop(sheetContext);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text('Save appliance'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    minController.dispose();
    maxController.dispose();
    capacityController.dispose();
    powerController.dispose();
  }

  static Future<void> _delete(
    BuildContext context,
    KitchenAppliance appliance,
  ) async {
    final state = AppScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove appliance?'),
        content: Text('Remove ${appliance.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      state.removeAppliance(appliance.id);
    }
  }
}

class _ApplianceCard extends StatelessWidget {
  const _ApplianceCard({
    required this.appliance,
    required this.onEdit,
    required this.onDelete,
  });

  final KitchenAppliance appliance;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final unit = state.temperatureUnit.symbol;

    final temperatureText = appliance.type.supportsTemperature
        ? '${state.displayTemperature(appliance.minCelsius)}–'
            '${state.displayTemperature(appliance.maxCelsius)}$unit'
        : appliance.powerWatts == null
            ? 'Power not set'
            : '${appliance.powerWatts} W';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF243321),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _iconFor(appliance.type),
            color: AppColors.primary,
          ),
        ),
        title: Text(
          appliance.name,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${appliance.type.label} · $temperatureText'
          '${appliance.preheatRequired ? ' · Preheat' : ''}',
          style: const TextStyle(color: AppColors.muted),
        ),
        onTap: onEdit,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Remove')),
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(ApplianceType type) {
    switch (type) {
      case ApplianceType.microwave:
        return Icons.microwave_outlined;
      case ApplianceType.airFryer:
        return Icons.air_outlined;
      case ApplianceType.slowCooker:
      case ApplianceType.pressureCooker:
      case ApplianceType.riceCooker:
        return Icons.soup_kitchen_outlined;
      case ApplianceType.stovetop:
        return Icons.local_fire_department_outlined;
      case ApplianceType.sousVide:
        return Icons.water_drop_outlined;
      default:
        return Icons.kitchen_outlined;
    }
  }
}

Future<void> openEquipment(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const EquipmentScreen()),
  );
}
