class StockItemModel {
  final int pk;
  final int part;
  final String partName;
  final double quantity;
  final String? locationName;
  final String? batch;
  final String? serial;
  final String? statusText;

  StockItemModel({
    required this.pk,
    required this.part,
    required this.partName,
    required this.quantity,
    this.locationName,
    this.batch,
    this.serial,
    this.statusText,
  });

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      pk: json['pk'] as int,
      part: json['part'] as int,
      partName: json['part_detail']?['name'] ?? 'Unknown Part',
      quantity: (json['quantity'] as num).toDouble(),
      locationName: json['location_detail']?['name'],
      batch: json['batch'],
      serial: json['serial'],
      statusText: json['status_label'],
    );
  }
}
