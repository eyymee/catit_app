import 'dart:convert';
import 'package:uuid/uuid.dart';

class GroceryItem {
  final String id;
  final String name;
  final bool isPurchased;

  GroceryItem({
    String? id,
    required this.name,
    this.isPurchased = false,
  }) : id = id ?? const Uuid().v4();

  GroceryItem copyWith({String? name, bool? isPurchased}) => GroceryItem(
        id: id,
        name: name ?? this.name,
        isPurchased: isPurchased ?? this.isPurchased,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isPurchased': isPurchased,
      };

  factory GroceryItem.fromJson(Map<String, dynamic> j) => GroceryItem(
        id: j['id'] as String,
        name: j['name'] as String,
        isPurchased: j['isPurchased'] as bool? ?? false,
      );

  String encode() => jsonEncode(toJson());
  static GroceryItem decode(String s) =>
      GroceryItem.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
