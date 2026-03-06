
import 'dart:io';

extension DoubleFormatting on double {
  String format([int digits = 2]) => toStringAsFixed(digits);
}

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
  
  @override
  String toString() => 'Student(id: $id, name: $name)';
}


class Assignment {
  final String name;
  final double maxScore;
  final double weight; 
  final String? dueDate;
  final String? description;
  
  Assignment({
    required this.name,
    required this.maxScore,
    required this.weight,
    this.dueDate,
    this.description,
  });
}


class Grade {
  final String studentId;
  final String assignmentName;
  final double? score;
  final String? submissionDate;
  final String? comments;
  
  Grade({
    required this.studentId,
    required this.assignmentName,
    this.score,
    this.submissionDate,
    this.comments,
  });
  
  // Calculated property using null-aware operator
  double get percentage => score ?? 0.0;
}


String toLetterGrade(double percentage) {
  if (percentage >= 90) return 'A';
  if (percentage >= 80) return 'B';
  if (percentage >= 70) return 'C';
  if (percentage >= 60) return 'D';
  return 'F';
}

/**
 * Gets grade description
 */
String getGradeDescription(double percentage) {
  if (percentage >= 90) return 'Excellent';
  if (percentage >= 80) return 'Good';
  if (percentage >= 70) return 'Satisfactory';
  if (percentage >= 60) return 'Needs Improvement';
  return 'Failing';
}


double? calculateFinalGrade({
  required String studentId,
  required List<Assignment> assignments,
  required List<Grade> grades,
  bool verbose = false,
}) {
  
  // Filter grades for this student
  final studentGrades = grades.where((g) => g.studentId == studentId).toList();
  
  if (studentGrades.isEmpty) {
    print('⚠️ No grades found for student ID: $studentId');
    return null;
  }
  
  // Calculate weighted total
  var totalWeightedScore = 0.0;
  var totalWeight = 0.0;
  
  for (var assignment in assignments) {
    // Find grade for this assignment
    final grade = studentGrades.firstWhere(
      (g) => g.assignmentName == assignment.name,
      orElse: () => Grade(studentId: studentId, assignmentName: assignment.name),
    );
    
    // Use null-aware operator to handle null scores
    final score = grade.score ?? 0.0;
    
    // Calculate weighted contribution
    final weightedContribution = score * assignment.weight;
    totalWeightedScore += weightedContribution;
    totalWeight += assignment.weight;
    
    if (verbose) {
      final scoreDisplay = grade.score?.toStringAsFixed(1) ?? 'MISSING';
      print('  ${assignment.name}: $scoreDisplay/${assignment.maxScore} → ${weightedContribution.toStringAsFixed(2)} pts');
    }
  }
  
  // Calculate final percentage
  return totalWeight > 0 ? (totalWeightedScore / totalWeight) * 100 : null;
}


List<T> processGrades<T>(List<Grade> grades, T Function(Grade) operation) {
  return grades.map(operation).toList();
}


List<Grade> filterGrades(List<Grade> grades, bool Function(Grade) predicate) {
  return grades.where(predicate).toList();
}


void main() {
  print('🎓 STUDENT GRADE CALCULATOR (DART VERSION)');
  print('=' * 60);
  
  // ==================== CREATE SAMPLE DATA ====================
  
  // Create students
  final students = [
    Student(
      id: 'S001', 
      name: 'Alice Wonder', 
      email: 'alice@email.com', 
      phoneNumber: '123-456-7890', 
      enrollmentYear: 2024
    ),
    Student(
      id: 'S002', 
      name: 'Bob Builder', 
      email: 'bob@email.com', 
      phoneNumber: null, 
      enrollmentYear: 2024
    ),
    Student(
      id: 'S003', 
      name: 'Charlie Brown', 
      email: null, 
      phoneNumber: '098-765-4321', 
      enrollmentYear: 2023
    ),
  ];
  
  print('\n📋 Registered Students:');
  for (var student in students) {
    print('  ${student.id}: ${student.name}');
    print('    Email: ${student.email ?? 'No email provided'}');
    print('    Phone: ${student.phoneNumber ?? 'No phone provided'}');
  }
  
  // Create assignments
  final assignments = [
    Assignment(
      name: 'Homework 1', 
      maxScore: 100.0, 
      weight: 0.10, 
      dueDate: '2026-02-01', 
      description: 'Basic Dart syntax'
    ),
    Assignment(
      name: 'Homework 2', 
      maxScore: 100.0, 
      weight: 0.10, 
      dueDate: '2026-02-08', 
      description: 'Functions and null safety'
    ),
    Assignment(
      name: 'Midterm Exam', 
      maxScore: 100.0, 
      weight: 0.30, 
      dueDate: '2026-02-22', 
      description: 'Covers weeks 1-4'
    ),
    Assignment(
      name: 'Final Project', 
      maxScore: 100.0, 
      weight: 0.40, 
      dueDate: '2026-03-15', 
      description: 'Complete Dart application'
    ),
    Assignment(
      name: 'Participation', 
      maxScore: 100.0, 
      weight: 0.10, 
      dueDate: null, 
      description: 'Class participation'
    ),
  ];
  
  print('\n📚 Course Assignments:');
  for (var assignment in assignments) {
    print('  ${assignment.name} (Weight: ${(assignment.weight * 100).toInt()}%)');
    if (assignment.description != null) {
      print('    📝 ${assignment.description}');
    }
  }
  
  // Create grades (with some nulls for missing submissions)
  final grades = [
    // Alice's grades
    Grade(studentId: 'S001', assignmentName: 'Homework 1', score: 95.0, submissionDate: '2026-02-01', comments: 'Great work!'),
    Grade(studentId: 'S001', assignmentName: 'Homework 2', score: 88.0, submissionDate: '2026-02-08', comments: null),
    Grade(studentId: 'S001', assignmentName: 'Midterm Exam', score: 92.0, submissionDate: '2026-02-22', comments: 'Excellent'),
    Grade(studentId: 'S001', assignmentName: 'Final Project', score: 95.0, submissionDate: '2026-03-15', comments: 'Outstanding project'),
    Grade(studentId: 'S001', assignmentName: 'Participation', score: 100.0, submissionDate: null, comments: 'Perfect attendance'),
    
    // Bob's grades (missing some)
    Grade(studentId: 'S002', assignmentName: 'Homework 1', score: 85.0, submissionDate: '2026-02-01', comments: null),
    Grade(studentId: 'S002', assignmentName: 'Homework 2', score: null, submissionDate: null, comments: 'Not submitted'),
    Grade(studentId: 'S002', assignmentName: 'Midterm Exam', score: 78.0, submissionDate: '2026-02-22', comments: 'Good effort'),
    Grade(studentId: 'S002', assignmentName: 'Final Project', score: 82.0, submissionDate: '2026-03-15', comments: 'Solid work'),
    // Bob missing participation grade
    
    // Charlie's grades
    Grade(studentId: 'S003', assignmentName: 'Homework 1', score: 100.0, submissionDate: '2026-02-01', comments: 'Perfect!'),
    Grade(studentId: 'S003', assignmentName: 'Homework 2', score: 95.0, submissionDate: '2026-02-08', comments: null),
    Grade(studentId: 'S003', assignmentName: 'Midterm Exam', score: 88.0, submissionDate: '2026-02-22', comments: null),
    Grade(studentId: 'S003', assignmentName: 'Final Project', score: 90.0, submissionDate: '2026-03-15', comments: null),
    Grade(studentId: 'S003', assignmentName: 'Participation', score: 85.0, submissionDate: null, comments: 'Good participation'),
  ];
  
  // ==================== CALCULATE AND DISPLAY GRADES ====================
  
  print('\n📊 GRADE CALCULATIONS');
  print('-' * 40);
  
  for (var student in students) {
    print('\n👤 Student: ${student.name} (${student.id})');
    
    final finalPercentage = calculateFinalGrade(
      studentId: student.id,
      assignments: assignments,
      grades: grades,
      verbose: true,
    );
    
    // Using null-aware operator for display
    final percentageDisplay = finalPercentage?.toStringAsFixed(1) ?? 'N/A';
    final letterGrade = finalPercentage != null ? toLetterGrade(finalPercentage) : 'N/A';
    final description = finalPercentage != null ? getGradeDescription(finalPercentage) : 'Incomplete';
    
    print('  ' + '-' * 30);
    print('  📈 Final Grade: $percentageDisplay%');
    print('  🏆 Letter Grade: $letterGrade');
    print('  📝 Status: $description');
  }
  
  // ==================== COLLECTION OPERATIONS ====================
  
  print('\n\n📈 ADVANCED ANALYTICS');
  print('=' * 60);
  
  // Using map to extract all scores
  final allScores = grades
      .where((g) => g.score != null)
      .map((g) => g.score!)
      .toList();
  
  print('\n📊 All scores: ${allScores..sort()}');
  
  if (allScores.isNotEmpty) {
    final avgScore = allScores.reduce((a, b) => a + b) / allScores.length;
    print('   Average score: ${avgScore.toStringAsFixed(1)}');
  }
  
  // Using filter to find missing submissions
  final missingSubmissions = filterGrades(grades, (grade) => grade.score == null);
  
  print('\n❌ Missing Submissions:');
  for (var grade in missingSubmissions) {
    final student = students.firstWhere(
      (s) => s.id == grade.studentId,
      orElse: () => Student(id: 'Unknown', name: 'Unknown', enrollmentYear: 0),
    ).name;
    print('  $student - ${grade.assignmentName}');
  }
  
  // Using groupBy to analyze by assignment
  print('\n📋 Assignment Performance:');
  
  final byAssignment = <String, List<Grade>>{};
  for (var grade in grades) {
    byAssignment.putIfAbsent(grade.assignmentName, () => []);
    byAssignment[grade.assignmentName]!.add(grade);
  }
  
  byAssignment.forEach((assignment, assignmentGrades) {
    final validScores = assignmentGrades
        .where((g) => g.score != null)
        .map((g) => g.score!)
        .toList();
    
    if (validScores.isNotEmpty) {
      final avg = validScores.reduce((a, b) => a + b) / validScores.length;
      final max = validScores.reduce((a, b) => a > b ? a : b);
      final min = validScores.reduce((a, b) => a < b ? a : b);
      print('  $assignment:');
      print('    Avg: ${avg.toStringAsFixed(1)} | Max: $max | Min: $min');
      print('    Submissions: ${validScores.length}/${students.length}');
    }
  });
  
  // Calculate class average
  final studentAverages = <double>[];
  for (var student in students) {
    final avg = calculateFinalGrade(
      studentId: student.id,
      assignments: assignments,
      grades: grades,
    );
    if (avg != null) {
      studentAverages.add(avg);
    }
  }
  
  final classAverage = studentAverages.isNotEmpty
      ? studentAverages.reduce((a, b) => a + b) / studentAverages.length
      : 0.0;
  
  print('\n🏫 Class Average: ${classAverage.toStringAsFixed(1)}%');
  
  // ==================== DEMO HIGHER-ORDER FUNCTIONS ====================
  
  print('\n\n🔄 HIGHER-ORDER FUNCTIONS DEMO');
  print('=' * 60);
  
  // Using processGrades to extract comments
  final allComments = processGrades<String>(
    grades, 
    (grade) => grade.comments ?? 'No comments'
  );
  
  print('\n💬 All comments:');
  allComments.take(5).forEach((comment, {index}) {
    print('  Comment ${allComments.indexOf(comment) + 1}: $comment');
  });
  
  // Custom predicate to find excellent grades (>= 90)
  final excellentGrades = filterGrades(grades, (grade) {
    return (grade.score ?? 0.0) >= 90.0;
  });
  
  print('\n🌟 Excellent Grades (>= 90%):');
  for (var grade in excellentGrades) {
    final student = students.firstWhere(
      (s) => s.id == grade.studentId,
      orElse: () => Student(id: 'Unknown', name: 'Unknown', enrollmentYear: 0),
    ).name;
    print('  $student - ${grade.assignmentName}: ${grade.score}%');
  }
  
  // ==================== SUMMARY REPORT ====================
  
  print('\n\n📋 FINAL SUMMARY REPORT');
  print('=' * 60);
  
  // Create a formatted report
  print('\n${'Student'.padRight(15)} ${'ID'.padRight(8)} ${'Grade'.padRight(8)} ${'Letter'.padRight(6)} Status');
  print('-' * 55);
  
  final sortedStudents = List.from(students)..sort((a, b) => a.name.compareTo(b.name));
  
  for (var student in sortedStudents) {
    final percentage = calculateFinalGrade(
      studentId: student.id,
      assignments: assignments,
      grades: grades,
    );
    
    final gradeStr = percentage?.toStringAsFixed(1).padRight(8) ?? 'N/A'.padRight(8);
    final letter = percentage != null ? toLetterGrade(percentage).padRight(6) : 'N/A'.padRight(6);
    final status = percentage != null 
        ? getGradeDescription(percentage).padRight(15) 
        : 'Incomplete'.padRight(15);
    
    print('${student.name.padRight(15)} ${student.id.padRight(8)} $gradeStr $letter $status');
  }
  
  print('\n' + '=' * 60);
  print('✅ Grade calculation complete!');
  
  // Save to file (bonus)
  try {
    final file = File('student_grades.csv');
    final sink = file.openWrite();
    
    sink.writeln('Student ID,Name,Final Grade,Letter Grade,Status');
    for (var student in students) {
      final percentage = calculateFinalGrade(
        studentId: student.id,
        assignments: assignments,
        grades: grades,
      );
      
      final percentageStr = percentage?.toStringAsFixed(1) ?? 'N/A';
      final letter = percentage != null ? toLetterGrade(percentage) : 'N/A';
      final status = percentage != null ? getGradeDescription(percentage) : 'Incomplete';
      
      sink.writeln('${student.id},${student.name},$percentageStr,$letter,$status');
    }
    
    sink.close();
    print('📁 Data saved to: ./student_grades.csv');
  } catch (e) {
    print('⚠️ Could not save to file: $e');
  }
}