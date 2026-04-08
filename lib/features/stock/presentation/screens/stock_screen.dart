import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inventree_app/features/stock/presentation/providers/stock_provider.dart';
import 'package:inventree_app/features/parts/presentation/providers/part_provider.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  Future<void> _exportStock(BuildContext context, dynamic items) async {
    List<List<dynamic>> rows = [];
    rows.add([
      "PK",
      "Part",
      "Quantity",
      "Location",
      "Batch",
      "Serial",
      "Status",
    ]);
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

  void _showAddStockDialog(BuildContext context, WidgetRef ref) {
    final quantityController = TextEditingController();
    int? selectedPartPk;

    final partsAsync = ref.read(partsProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Stock Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              partsAsync.when(
                data: (parts) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Select Part'),
                  items: parts
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.pk, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedPartPk = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading parts'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
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
                if (selectedPartPk == null) return;
                final double? qty = double.tryParse(quantityController.text);
                if (qty == null) return;

                try {
                  await ref.read(stockRepositoryProvider).createStockItem({
                    'part': selectedPartPk,
                    'quantity': qty,
                    // InvenTree requires a location for new stock items usually
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.invalidate(stockItemsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Stock added successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustStockDialog(
    BuildContext context,
    WidgetRef ref,
    int itemPk,
    String partName,
    double currentQuantity,
  ) {
    final TextEditingController quantityController = TextEditingController();
    String action = 'add';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Adjust Stock: $partName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Quantity: $currentQuantity'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: action,
                items: const [
                  DropdownMenuItem(value: 'add', child: Text('Add Stock (+)')),
                  DropdownMenuItem(
                    value: 'remove',
                    child: Text('Remove Stock (-)'),
                  ),
                ],
                onChanged: (val) => setState(() => action = val!),
                decoration: const InputDecoration(labelText: 'Action'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
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
                final double? qty = double.tryParse(quantityController.text);
                if (qty == null || qty <= 0) return;
                try {
                  await ref
                      .read(stockRepositoryProvider)
                      .adjustStock(itemPk, qty, action);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.invalidate(stockItemsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Stock adjusted')),
                    );
                  }
                } catch (e) {
                  if (context.mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
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
              tooltip: 'Export CSV',
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
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
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    onPressed: () => _showAdjustStockDialog(
                      context,
                      ref,
                      item.pk,
                      item.partName,
                      item.quantity,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      try {
                        await ref
                            .read(stockRepositoryProvider)
                            .deleteStockItem(item.pk);
                        ref.invalidate(stockItemsProvider);
                      } catch (e) {
                        if (context.mounted)
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStockDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
