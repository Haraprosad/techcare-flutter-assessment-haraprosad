import 'package:equatable/equatable.dart';

/// Category entity for transactions
class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;
  final double? budget;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.budget,
  });

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    double? budget,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budget: budget ?? this.budget,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, color, budget];
}
