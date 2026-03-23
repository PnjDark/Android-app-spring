// main_interactive.dart
import 'dart:io';

// ==================== MODELS ====================

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
  String toString() => '$name ($id)';
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
  
  @override
  String toString() => '$name (${(weight * 100).toInt()}%)';
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
}

// ==================== LOGIC ====================

String toLetterGrade(double percentage) {
  if (percentage >= 90) return 'A';
  if (percentage >= 80) return 'B';
  if (percentage >= 70) return 'C';
  if (percentage >= 60) return 'D';
  return 'F';
}

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

// ==================== INTERACTIVE MAIN ====================

void main() {
  print('🎓 STUDENT GRADE CALCULATOR - INTERACTIVE MODE');
  print('=' * 50);
  
  // Sample data (hardcoded for now)
  final students = [
    Student(id: 'S001', name: 'Alice Wonder', email: 'alice@email.com', enrollmentYear: 2024),
    Student(id: 'S002', name: 'Bob Builder', email: 'bob@email.com', enrollmentYear: 2024),
    Student(id: 'S003', name: 'Charlie Brown', enrollmentYear: 2023),
  ];
  
  final assignments = [
    Assignment(id: 'A001', name: 'Homework 1', maxScore: 100, weight: 0.10),
    Assignment(id: 'A002', name: 'Homework 2', maxScore: 100, weight: 0.10),
    Assignment(id: 'A003', name: 'Midterm Exam', maxScore: 100, weight: 0.30),
    Assignment(id: 'A004', name: 'Final Project', maxScore: 100, weight: 0.40),
    Assignment(id: 'A005', name: 'Participation', maxScore: 100, weight: 0.10),
  ];
  
  final grades = [
    Grade(studentId: 'S001', assignmentId: 'A001', score: 95.0),
    Grade(studentId: 'S001', assignmentId: 'A002', score: 88.0),
    Grade(studentId: 'S001', assignmentId: 'A003', score: 92.0),
    Grade(studentId: 'S001', assignmentId: 'A004', score: 95.0),
    Grade(studentId: 'S001', assignmentId: 'A005', score: 100.0),
    Grade(studentId: 'S002', assignmentId: 'A001', score: 85.0),
    Grade(studentId: 'S002', assignmentId: 'A002', score: null),
    Grade(studentId: 'S002', assignmentId: 'A003', score: 78.0),
    Grade(studentId: 'S002', assignmentId: 'A004', score: 82.0),
  ];
  
  while (true) {
    print('\n' + '=' * 50);
    print('MAIN MENU');
    print('1. Look up student grade');
    print('2. View all students');
    print('3. Exit');
    print('=' * 50);
    
    stdout.write('Enter your choice (1-3): ');
    String? choice = stdin.readLineSync();
    
    if (choice == '3') {
      print('\n👋 Goodbye!');
      break;
    } else if (choice == '2') {
      print('\n📋 STUDENT LIST:');
      for (var student in students) {
        print('  ${student.id}: ${student.name}');
      }
      print('\nPress Enter to continue...');
      stdin.readLineSync();
    } else if (choice == '1') {
      print('\n🔍 STUDENT GRADE LOOKUP');
      print('Available students:');
      for (var student in students) {
        print('  ${student.id}: ${student.name}');
      }
      
      stdout.write('\nEnter student ID: ');
      String? studentId = stdin.readLineSync();
      
      if (studentId != null && studentId.isNotEmpty) {
        final student = students.firstWhere(
          (s) => s.id == studentId,
          orElse: () => Student(id: '', name: '', enrollmentYear: 0),
        );
        
        if (student.id.isEmpty) {
          print('❌ Student not found!');
        } else {
          final percentage = calculateFinalGrade(
            studentId: studentId,
            assignments: assignments,
            grades: grades,
          );
          
          print('\n📊 RESULTS FOR ${student.name}:');
          if (percentage != null) {
            print('  Final Grade: ${percentage.toStringAsFixed(1)}%');
            print('  Letter Grade: ${toLetterGrade(percentage)}');
          } else {
            print('  No grades available for this student.');
          }
        }
      }
      
      print('\nPress Enter to continue...');
      stdin.readLineSync();
    } else {
      print('❌ Invalid choice!');
      sleep(Duration(seconds: 1));
    }
  }
}