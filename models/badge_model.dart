class BadgeModel {
  final String id;
  final String name;
  final String area;
  final String level;
  final int points;
  final bool isRecommended;

  BadgeModel({
    required this.id,
    required this.name,
    required this.area,
    required this.level,
    required this.points,
    required this.isRecommended,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'],
      name: json['name'],
      area: json['area'],
      level: json['level'],
      points: json['points'],
      isRecommended: json['isRecommended'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'level': level,
      'points': points,
      'isRecommended': isRecommended ? 1 : 0,
    };
  }
  
  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      id: map['id'],
      name: map['name'],
      area: map['area'],
      level: map['level'],
      points: map['points'],
      isRecommended: map['isRecommended'] == 1,
    );
  }
}
