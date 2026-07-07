enum MenuItemCategory {
  food('food'),
  drink('drink'),
  dessert('dessert'),
  snack('snack');

  final String jsonValue;
  const MenuItemCategory(this.jsonValue);

  static MenuItemCategory fromJson(String value) {
    return MenuItemCategory.values.firstWhere(
      (category) => category.jsonValue == value,
      orElse: () => MenuItemCategory.food,
    );
  }
}

class MenuItem {
  final String itemName;
  final String description;
  final int calories;
  final double? price;
  final bool isTypicalLocalProduct;
  final MenuItemCategory category;

  const MenuItem({
    required this.itemName,
    required this.description,
    required this.calories,
    this.price,
    required this.isTypicalLocalProduct,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemName: json['itemName'] as String,
      description: json['description'] as String,
      calories: json['calories'] as int,
      price: (json['price'] as num?)?.toDouble(),
      isTypicalLocalProduct: json['isTypicalLocalProduct'] as bool? ?? false,
      category: MenuItemCategory.fromJson(json['category'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'description': description,
      'calories': calories,
      'price': price,
      'isTypicalLocalProduct': isTypicalLocalProduct,
      'category': category.jsonValue,
    };
  }
}
