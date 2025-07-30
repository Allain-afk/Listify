import 'package:uuid/uuid.dart';

enum GroceryCategory {
  fruits,
  vegetables,
  dairy,
  meat,
  pantry,
  beverages,
  snacks,
  household,
  other,
}

class GroceryItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final GroceryCategory category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  const GroceryItem({
    String? id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.category = GroceryCategory.other,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  double get totalPrice => price * quantity;

  GroceryItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    GroceryCategory? category,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    String? notes,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'category': category.index,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map['id'],
      name: map['name'],
      price: map['price']?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 1,
      category: GroceryCategory.values[map['category'] ?? 0],
      isCompleted: (map['isCompleted'] ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      notes: map['notes'],
    );
  }

  @override
  String toString() {
    return 'GroceryItem(id: $id, name: $name, price: $price, quantity: $quantity, category: $category, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroceryItem &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity &&
        other.category == category &&
        other.isCompleted == isCompleted &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        category.hashCode ^
        isCompleted.hashCode ^
        notes.hashCode;
  }
} 