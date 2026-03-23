class Student {
  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final int enrollmentYear;
  
  Student({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    required this.enrollmentYear,
  });
}

class Assignment {
  final String id;
  final String name;
  final double maxScore;
  final double weight;
  final String? dueDate;
  final String? description;
  
  Assignment({
    required this.id,
    required this.name,
    required this.maxScore,
    required this.weight,
    this.dueDate,
    this.description,
  });
}

class Grade {
  final String studentId;
  final String assignmentId;
  double? score;
  String? submissionDate;
  String? comments;
  
  Grade({
    required this.studentId,
    required this.assignmentId,
    this.score,
    this.submissionDate,
    this.comments,
  });
  
  // Check if grade exists
  bool get hasScore => score != null;
}