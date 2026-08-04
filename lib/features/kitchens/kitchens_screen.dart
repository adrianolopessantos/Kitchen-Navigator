import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../models/kitchen_profile.dart';

class KitchensScreen extends StatelessWidget {
  const KitchensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Kitchens')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add kitchen'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            const Text(
              'Kitchen locations',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Each location has its own pantry, meal plan, shopping progress, and appliances.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            ...state.kitchenProfiles.map(
              (profile) => _KitchenCard(
                profile: profile,
                active: profile.id == state.activeKitchenId,
                onSelect: () => state.switchKitchen(profile.id),
                onEdit: () => _showEditor(
                  context,
                  existing: profile,
                ),
                onDelete: () => _delete(context, profile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showEditor(
    BuildContext context, {
    KitchenProfile? existing,
  }) async {
    final state = AppScope.of(context);
    final nameController = TextEditingController(
      text: existing?.name ?? '',
    );
    var iconName = existing?.iconName ?? 'home';

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
                      existing == null ? 'Add kitchen' : 'Edit kitchen',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      autofocus: existing == null,
                      decoration: const InputDecoration(
                        labelText: 'Kitchen name',
                        hintText: 'Home, Camper, Office...',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Icon',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        ('home', Icons.home_outlined),
                        ('holiday', Icons.beach_access_outlined),
                        ('camper', Icons.directions_car_outlined),
                        ('office', Icons.business_outlined),
                        ('cabin', Icons.cottage_outlined),
                        ('boat', Icons.sailing_outlined),
                      ].map((entry) {
                        return ChoiceChip(
                          selected: iconName == entry.$1,
                          onSelected: (_) => setModalState(
                            () => iconName = entry.$1,
                          ),
                          avatar: Icon(entry.$2, size: 18),
                          label: Text(entry.$1),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a kitchen name.'),
                              ),
                            );
                            return;
                          }

                          if (existing == null) {
                            await state.addKitchenProfile(
                              name: name,
                              iconName: iconName,
                            );
                          } else {
                            await state.updateKitchenProfile(
                              existing.copyWith(
                                name: name,
                                iconName: iconName,
                              ),
                            );
                          }

                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text('Save kitchen'),
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
  }

  static Future<void> _delete(
    BuildContext context,
    KitchenProfile profile,
  ) async {
    final state = AppScope.of(context);

    if (state.kitchenProfiles.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one kitchen must remain.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove kitchen?'),
        content: Text(
          'Remove ${profile.name} and all data stored for this location?',
        ),
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
      await state.removeKitchenProfile(profile.id);
    }
  }
}

class _KitchenCard extends StatelessWidget {
  const _KitchenCard({
    required this.profile,
    required this.active,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final KitchenProfile profile;
  final bool active;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF2C4527)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _iconFor(profile.iconName),
            color: active ? AppColors.primary : AppColors.muted,
          ),
        ),
        title: Text(
          profile.name,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          active ? 'Currently active' : 'Tap to switch',
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.muted,
          ),
        ),
        onTap: onSelect,
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

  static IconData _iconFor(String value) {
    switch (value) {
      case 'holiday':
        return Icons.beach_access_outlined;
      case 'camper':
        return Icons.directions_car_outlined;
      case 'office':
        return Icons.business_outlined;
      case 'cabin':
        return Icons.cottage_outlined;
      case 'boat':
        return Icons.sailing_outlined;
      default:
        return Icons.home_outlined;
    }
  }
}

Future<void> openKitchens(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const KitchensScreen()),
  );
}
