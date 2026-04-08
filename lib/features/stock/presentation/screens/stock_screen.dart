import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inventree_app/features/stock/presentation/providers/stock_provider.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  Future<void> _exportStock(BuildContext context, dynamic items) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      "PK",
      "Part",
      "Quantity",
      "Location",
      "Batch",
      "Serial",
      "Status",
    ]);

    // Data
    for (var item in items) {
      rows.add([
        item.pk,
        item.partName,
        item.quantity,
        item.locationName ?? "",
        item.batch ?? "",
        item.serial ?? "",
        item.statusText ?? "",
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Stock Export',
      fileName: 'inventree_stock_export.csv',
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
    final stockAsync = ref.watch(stockItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Items'),
        actions: [
          stockAsync.maybeWhen(
            data: (items) => IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Export to CSV',
              onPressed: () => _exportStock(context, items),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(stockItemsProvider),
          ),
        ],
      ),
      body: stockAsync.when(
        data: (items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.inventory)),
              title: Text(item.partName),
              subtitle: Text(item.locationName ?? 'No Location'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (item.statusText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.statusText!,
                        style: const TextStyle(fontSize: 10),
                      ),
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
                onPressed: () => ref.refresh(stockItemsProvider),
                child: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
