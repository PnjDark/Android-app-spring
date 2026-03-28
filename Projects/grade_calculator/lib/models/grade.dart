class Grade {
  final String studentId;
  final String assignmentId;
  final double? score;
  final DateTime? submissionDate;
  final String? comments;

  Grade({
    required this.studentId,
    required this.assignmentId,
    this.score,
    this.submissionDate,
    this.comments,
  });
}
