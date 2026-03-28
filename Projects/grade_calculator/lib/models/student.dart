class Student {
  final String id;
  final String name;
  final String? email;
  final int enrollmentYear;

  Student({
    required this.id,
    required this.name,
    this.email,
    required this.enrollmentYear,
  });
}
