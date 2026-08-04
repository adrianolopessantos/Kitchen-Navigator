class KitchenProfile {
  const KitchenProfile({
    required this.id,
    required this.name,
    required this.iconName,
  });

  final String id;
  final String name;
  final String iconName;

  KitchenProfile copyWith({
    String? name,
    String? iconName,
  }) {
    return KitchenProfile(
      id: id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
    );
  }
}
