import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../models/student.dart';
import '../models/assignment.dart';
import '../models/grade.dart';

enum InputFormat { csv, excel }

class FileParser {
  /// Parse a CSV file into models.
  static Future<ParsedData> parseCsv(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    // The csv package's auto-detection can be finicky with mixed EOL or single-line inputs.
    // We'll normalize to \n and use that for robust parsing.
    final normalizedContent = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final rows = const CsvToListConverter().convert(normalizedContent, eol: '\n');
    return _parseRows(rows);
  }

  /// Parse an Excel file into models.
  static Future<ParsedData> parseExcel(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final students = <Student>[];
    final assignments = <Assignment>[];
    final grades = <Grade>[];

    // Try to find sheets by name, or fallback to index 0,1,2
    final sheetNames = excel.sheets.keys.toList();
    if (sheetNames.contains('Students')) {
      _parseStudentSheet(excel.tables['Students']!, students);
    } else if (sheetNames.length > 0) {
      _parseStudentSheet(excel.tables[sheetNames[0]]!, students);
    }

    if (sheetNames.contains('Assignments')) {
      _parseAssignmentSheet(excel.tables['Assignments']!, assignments);
    } else if (sheetNames.length > 1) {
      _parseAssignmentSheet(excel.tables[sheetNames[1]]!, assignments);
    }

    if (sheetNames.contains('Grades')) {
      _parseGradeSheet(excel.tables['Grades']!, grades);
    } else if (sheetNames.length > 2) {
      _parseGradeSheet(excel.tables[sheetNames[2]]!, grades);
    }

    return ParsedData(students: students, assignments: assignments, grades: grades);
  }

  static void _parseStudentSheet(Sheet sheet, List<Student> students) {
    // Assume header row: ID, Name, Email, EnrollmentYear
    for (var row in sheet.rows.skip(1)) {
      if (row.length < 2) continue;
      final id = row[0]?.value?.toString() ?? '';
      final name = row[1]?.value?.toString() ?? '';
      final email = row.length > 2 ? row[2]?.value?.toString() : null;
      final year = row.length > 3 ? int.tryParse(row[3]?.value?.toString() ?? '') ?? 2024 : 2024;
      if (id.isNotEmpty && name.isNotEmpty) {
        students.add(Student(id: id, name: name, email: email, enrollmentYear: year));
      }
    }
  }

  static void _parseAssignmentSheet(Sheet sheet, List<Assignment> assignments) {
    // Header: ID, Name, MaxScore, Weight, DueDate (optional)
    for (var row in sheet.rows.skip(1)) {
      if (row.length < 4) continue;
      final id = row[0]?.value?.toString() ?? '';
      final name = row[1]?.value?.toString() ?? '';
      final maxScore = double.tryParse(row[2]?.value?.toString() ?? '') ?? 100.0;
      final weight = double.tryParse(row[3]?.value?.toString() ?? '') ?? 0.0;
      DateTime? dueDate;
      if (row.length > 4 && row[4]?.value != null) {
        dueDate = DateTime.tryParse(row[4]!.value.toString());
      }
      if (id.isNotEmpty && name.isNotEmpty) {
        assignments.add(Assignment(
          id: id,
          name: name,
          maxScore: maxScore,
          weight: weight,
          dueDate: dueDate,
        ));
      }
    }
  }

  static void _parseGradeSheet(Sheet sheet, List<Grade> grades) {
    // Header: StudentID, AssignmentID, Score, SubmissionDate, Comments
    for (var row in sheet.rows.skip(1)) {
      if (row.length < 3) continue;
      final studentId = row[0]?.value?.toString() ?? '';
      final assignmentId = row[1]?.value?.toString() ?? '';
      final score = double.tryParse(row[2]?.value?.toString() ?? '');
      DateTime? submissionDate;
      if (row.length > 3 && row[3]?.value != null) {
        submissionDate = DateTime.tryParse(row[3]!.value.toString());
      }
      final comments = row.length > 4 ? row[4]?.value?.toString() : null;
      if (studentId.isNotEmpty && assignmentId.isNotEmpty) {
        grades.add(Grade(
          studentId: studentId,
          assignmentId: assignmentId,
          score: score,
          submissionDate: submissionDate,
          comments: comments,
        ));
      }
    }
  }

  static ParsedData _parseRows(List<List<dynamic>> rows) {
    final students = <Student>[];
    final assignments = <Assignment>[];
    final grades = <Grade>[];
    for (var row in rows) {
      if (row.isEmpty) continue;
      final type = row[0]?.toString().toLowerCase();
      switch (type) {
        case 'student':
          if (row.length >= 3) {
            students.add(Student(
              id: row[1]?.toString() ?? '',
              name: row[2]?.toString() ?? '',
              email: row.length > 3 ? row[3]?.toString() : null,
              enrollmentYear: row.length > 4 ? int.tryParse(row[4]?.toString() ?? '') ?? 2024 : 2024,
            ));
          }
          break;
        case 'assignment':
          if (row.length >= 5) {
            assignments.add(Assignment(
              id: row[1]?.toString() ?? '',
              name: row[2]?.toString() ?? '',
              maxScore: double.tryParse(row[3]?.toString() ?? '') ?? 100,
              weight: double.tryParse(row[4]?.toString() ?? '') ?? 0,
            ));
          }
          break;
        case 'grade':
          if (row.length >= 4) {
            grades.add(Grade(
              studentId: row[1]?.toString() ?? '',
              assignmentId: row[2]?.toString() ?? '',
              score: double.tryParse(row[3]?.toString() ?? ''),
              submissionDate: row.length > 4 ? DateTime.tryParse(row[4]?.toString() ?? '') : null,
              comments: row.length > 5 ? row[5]?.toString() : null,
            ));
          }
          break;
      }
    }
    return ParsedData(students: students, assignments: assignments, grades: grades);
  }
}

class ParsedData {
  final List<Student> students;
  final List<Assignment> assignments;
  final List<Grade> grades;
  ParsedData({required this.students, required this.assignments, required this.grades});
}
