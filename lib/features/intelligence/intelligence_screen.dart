import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'ai_kitchen_screen.dart';

class IntelligenceScreen extends StatelessWidget {
  const IntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Kitchen Intelligence',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Meal suggestions based on pantry contents, expiry urgency and available cooking time.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => openAiKitchen(context),
            icon: const Icon(Icons.auto_awesome),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text('Open AI Kitchen Preview'),
            ),
          ),
        ],
      ),
    );
  }
}
