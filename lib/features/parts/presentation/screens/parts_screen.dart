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
    );
  }
}
