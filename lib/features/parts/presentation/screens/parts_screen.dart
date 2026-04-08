import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inventree_app/features/parts/presentation/providers/part_provider.dart';

class PartsScreen extends ConsumerWidget {
  const PartsScreen({super.key});

  Future<void> _exportParts(BuildContext context, dynamic parts) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add(["PK", "Name", "IPN", "Category", "Description", "Stock"]);

    // Data
    for (var part in parts) {
      rows.add([
        part.pk,
        part.name,
        part.ipn ?? "",
        part.categoryName ?? "",
        part.description,
        part.stock ?? 0,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Parts Export',
      fileName: 'inventree_parts_export.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(csvData);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Exported to $outputFile')));
      }
    }
  }

  void _showAddPartDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final ipnController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Part'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Part Name *'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: ipnController,
              decoration: const InputDecoration(labelText: 'IPN'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
                return;
              }

              try {
                await ref.read(partRepositoryProvider).createPart({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'IPN': ipnController.text,
                  // Note: InvenTree often requires a category PK.
                  // For simplicity in this demo, we assume a default or optional category.
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(partsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Part created successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create part: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsAsync = ref.watch(partsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parts'),
        actions: [
          partsAsync.maybeWhen(
            data: (parts) => IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Export to CSV',
              onPressed: () => _exportParts(context, parts),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
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
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Part?'),
                          content: Text(
                            'Are you sure you want to delete ${part.name}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await ref
                              .read(partRepositoryProvider)
                              .deletePart(part.pk);
                          ref.invalidate(partsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Part deleted')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete: $e')),
                            );
                          }
                        }
                      }
                    },
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
              const Text('Offline Mode - Using Cached Data'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(partsProvider),
                child: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPartDialog(context, ref),
        tooltip: 'Add Part',
        child: const Icon(Icons.add),
      ),
    );
  }
}
