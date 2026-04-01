import 'package:flutter/material.dart';
import 'seed_data.dart';

class SeedDataButton extends StatelessWidget {
  const SeedDataButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final seeder = DatabaseSeeder();
        await seeder.seedAllData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database seeded successfully!')),
        );
      },
      icon: const Icon(Icons.cloud_upload),
      label: const Text('Seed Demo Data'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}
