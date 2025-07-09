class Unit {
  final String name;
  final num grams;

  const Unit({required this.name, required this.grams});

  Map<String, dynamic> toMap() {
    return {'name': name, 'grams': grams};
  }

  factory Unit.fromMap(Map<String, dynamic> map) {
    if (map case {'name': String name, 'grams': num grams}) {
      return Unit(name: name, grams: grams);
    } else {
      throw const FormatException('Invalid JSON format for Unit');
    }
  }

  Unit copyWith({String? name, num? grams}) {
    return Unit(name: name ?? this.name, grams: grams ?? this.grams);
  }
}
