import 'models.dart';

// Grade calculation logic
String toLetterGrade(double percentage) {
  if (percentage >= 90) return 'A';
  if (percentage >= 80) return 'B';
  if (percentage >= 70) return 'C';
  if (percentage >= 60) return 'D';
  return 'F';
}

String getGradeDescription(double percentage) {
  if (percentage >= 90) return 'Excellent';
  if (percentage >= 80) return 'Good';
  if (percentage >= 70) return 'Satisfactory';
  if (percentage >= 60) return 'Needs Improvement';
  return 'Failing';
}

// Color getGradeColor(double percentage) {
//   if (percentage >= 90) return Color(0xFF2E7D32);  // Dark Green
//   if (percentage >= 80) return Color(0xFF558B2F);  // Light Green
//   if (percentage >= 70) return Color(0xFFF57C00);  // Orange
//   if (percentage >= 60) return Color(0xFFE65100);  // Deep Orange
//   return Color(0xFFC62828);  // Red
// }

double? calculateFinalGrade({
  required String studentId,
  required List<Assignment> assignments,
  required List<Grade> grades,
}) {
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
    totalWeightedScore += score * assignment.weight;
    totalWeight += assignment.weight;
  }
  
  return totalWeight > 0 ? (totalWeightedScore / totalWeight) * 100 : null;
}

// NEW: Save or update grade
void saveOrUpdateGrade({
  required String studentId,
  required String assignmentId,
  required double score,
  required List<Grade> grades,
}) {
  // Check if grade already exists
  final existingIndex = grades.indexWhere(
    (g) => g.studentId == studentId && g.assignmentId == assignmentId,
  );
  
  if (existingIndex >= 0) {
    // Update existing grade
    grades[existingIndex].score = score;
  } else {
    // Create new grade
    grades.add(Grade(
      studentId: studentId,
      assignmentId: assignmentId,
      score: score,
    ));
  }
}

// Get existing score for student/assignment combo
double? getExistingScore({
  required String studentId,
  required String assignmentId,
  required List<Grade> grades,
}) {
  final grade = grades.firstWhere(
    (g) => g.studentId == studentId && g.assignmentId == assignmentId,
    orElse: () => Grade(studentId: studentId, assignmentId: assignmentId),
  );
  return grade.score;
}