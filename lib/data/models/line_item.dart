class LineItem {
  int? itemId;
  String name;
  int quantity;
  double price;
  String? description;
  String discountType;
  double discount;
  double discountVal;
  double tax;
  double total;
  String? unitName;

  LineItem({
    this.itemId,
    this.name = '',
    this.quantity = 1,
    this.price = 0,
    this.description,
    this.discountType = 'fixed',
    this.discount = 0,
    this.discountVal = 0,
    this.tax = 0,
    this.total = 0,
    this.unitName,
  });

  void recalculate() {
    double lineTotal = quantity * price;
    if (discountType == 'percentage') {
      discountVal = lineTotal * (discount / 100);
    } else {
      discountVal = discount;
    }
    total = lineTotal - discountVal + tax;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': (price * 100).round(),
      if (description != null && description!.isNotEmpty) 'description': description,
      'discount_type': discountType,
      'discount': discount,
      'discount_val': (discountVal * 100).round(),
      'tax': (tax * 100).round(),
      'total': (total * 100).round(),
      if (itemId != null) 'item_id': itemId,
      if (unitName != null) 'unit_name': unitName,
    };
  }
}
