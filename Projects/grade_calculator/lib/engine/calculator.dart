import '../models/student.dart';
import '../models/assignment.dart';
import '../models/grade.dart';

class GradeCalculator {
  final List<Student> students;
  final List<Assignment> assignments;
  final List<Grade> grades;

  GradeCalculator({
    required this.students,
    required this.assignments,
    required this.grades,
  });

  double? calculateStudentGrade(String studentId) {
    final studentGrades = grades.where((g) => g.studentId == studentId).toList();
    if (studentGrades.isEmpty) return null;

    var totalWeightedScore = 0.0;
    var totalWeight = 0.0;

    for (var assignment in assignments) {
      final grade = studentGrades.firstWhere(
        (g) => g.assignmentId == assignment.id,
        orElse: () => Grade(studentId: studentId, assignmentId: assignment.id),
      );

      final score = grade.score ?? 0.0;
      // Convert score to percentage of max score for that assignment
      final percentage = (score / assignment.maxScore);
      totalWeightedScore += percentage * assignment.weight;
      totalWeight += assignment.weight;
    }

    return totalWeight > 0 ? (totalWeightedScore / totalWeight) * 100 : null;
  }

  Map<String, dynamic> getClassStatistics() {
    final results = students
        .map((s) => calculateStudentGrade(s.id))
        .where((g) => g != null)
        .cast<double>()
        .toList();

    if (results.isEmpty) {
      return {
        'average': 0.0,
        'highest': 0.0,
        'lowest': 0.0,
        'count': 0,
        'distribution': {'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0}
      };
    }

    final average = results.reduce((a, b) => a + b) / results.length;
    final highest = results.reduce((a, b) => a > b ? a : b);
    final lowest = results.reduce((a, b) => a < b ? a : b);

    final distribution = {'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0};
    for (var grade in results) {
      distribution[grade.toLetterGrade()] = (distribution[grade.toLetterGrade()] ?? 0) + 1;
    }

    return {
      'average': average,
      'highest': highest,
      'lowest': lowest,
      'count': results.length,
      'distribution': distribution,
    };
  }
}

extension GradeFormatting on double {
  String toLetterGrade() {
    if (this >= 90) return 'A';
    if (this >= 80) return 'B';
    if (this >= 70) return 'C';
    if (this >= 60) return 'D';
    return 'F';
  }

  String toDescription() {
    if (this >= 90) return 'Excellent';
    if (this >= 80) return 'Good';
    if (this >= 70) return 'Satisfactory';
    if (this >= 60) return 'Needs Improvement';
    return 'Failing';
  }
}
