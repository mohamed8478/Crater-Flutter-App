class Item {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int? unitId;
  final String? unitName;
  final String? createdAt;

  Item({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.unitId,
    this.unitName,
    this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: ((json['price'] ?? 0) as num).toDouble() / 100.0,
      unitId: json['unit_id'],
      unitName: json['unit']?['name'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': (price * 100).round(),
      if (description != null) 'description': description,
      if (unitId != null) 'unit_id': unitId,
    };
  }
}

class ItemListResponse {
  final List<Item> items;
  final int total;
  final int currentPage;
  final int lastPage;

  ItemListResponse({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory ItemListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?) ?? [];
    final meta = (json['meta'] as Map<String, dynamic>?) ?? {};
    return ItemListResponse(
      items: list.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList(),
      total: meta['total'] ?? list.length,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
    );
  }
}
