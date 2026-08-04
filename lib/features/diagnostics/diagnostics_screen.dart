import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final snapshot = state.diagnosticsSnapshot;

    return Scaffold(
      appBar: AppBar(title: const Text('App Diagnostics')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Kitchen Navigator health check',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Use this screen to confirm that the main modules loaded correctly.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _DiagnosticRow(
                    label: 'Local data loaded',
                    value: snapshot['dataLoaded'] == true ? 'Yes' : 'No',
                    ok: snapshot['dataLoaded'] == true,
                  ),
                  _DiagnosticRow(
                    label: 'Active kitchen',
                    value: '${snapshot['activeKitchen']}',
                    ok: true,
                  ),
                  _DiagnosticRow(
                    label: 'Kitchen profiles',
                    value: '${snapshot['kitchens']}',
                    ok: (snapshot['kitchens'] as int) >= 1,
                  ),
                  _DiagnosticRow(
                    label: 'Pantry products',
                    value: '${snapshot['pantryItems']}',
                    ok: true,
                  ),
                  _DiagnosticRow(
                    label: 'Planned meals',
                    value: '${snapshot['plannedMeals']}',
                    ok: true,
                  ),
                  _DiagnosticRow(
                    label: 'Shopping products',
                    value: '${snapshot['shoppingItems']}',
                    ok: true,
                  ),
                  _DiagnosticRow(
                    label: 'Kitchen appliances',
                    value: '${snapshot['appliances']}',
                    ok: true,
                  ),
                  _DiagnosticRow(
                    label: 'Expiry alerts',
                    value:
                        '${snapshot['expiredItems']} expired · ${snapshot['expiringSoon']} soon',
                    ok: (snapshot['expiredItems'] as int) == 0,
                  ),
                  _DiagnosticRow(
                    label: 'Low-stock alerts',
                    value: '${snapshot['lowStockItems']}',
                    ok: true,
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.surfaceElevated,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'This release consolidates the v9.3 and v9.4 AppState fixes before new major features are added.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({
    required this.label,
    required this.value,
    required this.ok,
    this.last = false,
  });

  final String label;
  final String value;
  final bool ok;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            ok ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: ok ? AppColors.primary : AppColors.warning,
          ),
          title: Text(label),
          trailing: Text(
            value,
            style: TextStyle(
              color: ok ? AppColors.text : AppColors.warning,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (!last) const Divider(height: 1),
      ],
    );
  }
}

Future<void> openDiagnostics(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const DiagnosticsScreen()),
  );
}
