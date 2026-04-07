import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventree_app/features/parts/presentation/providers/part_provider.dart';

class PartsScreen extends ConsumerWidget {
  const PartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsAsync = ref.watch(partsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(partsProvider),
          ),
        ],
      ),
      body: partsAsync.when(
        data: (parts) => ListView.separated(
          itemCount: parts.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final part = parts[index];
            return ListTile(
              leading: part.image != null
                  ? Image.network(
                      part.image!,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    )
                  : const Icon(Icons.category, size: 40),
              title: Text(part.name),
              subtitle: Text(part.description),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Stock: ${part.stock ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (part.categoryName != null)
                    Text(
                      part.categoryName!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error loading parts: $err'),
              ElevatedButton(
                onPressed: () => ref.refresh(partsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
