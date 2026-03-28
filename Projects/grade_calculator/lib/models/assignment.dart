class Assignment {
  final String id;
  final String name;
  final double maxScore;
  final double weight;
  final DateTime? dueDate;

  Assignment({
    required this.id,
    required this.name,
    required this.maxScore,
    required this.weight,
    this.dueDate,
  });

  double get weightPercent => weight * 100;
}
