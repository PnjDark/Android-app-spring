import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../models/student.dart';
import '../models/assignment.dart';
import '../models/grade.dart';
import '../engine/calculator.dart';

class FileWriter {
  /// Export results to CSV.
  static Future<void> toCsv(
    String filePath,
    List<Student> students,
    List<Assignment> assignments,
    GradeCalculator calculator,
  ) async {
    final List<List<dynamic>> rows = [];

    // Header row: student info + assignments + final grade
    final header = ['Student ID', 'Student Name'];
    header.addAll(assignments.map((a) => a.name));
    header.addAll(['Final Grade (%)', 'Letter Grade', 'Status']);
    rows.add(header);

    for (var student in students) {
      final row = <dynamic>[student.id, student.name];
      for (var assignment in assignments) {
        final grade = calculator.grades.firstWhere(
          (g) => g.studentId == student.id && g.assignmentId == assignment.id,
          orElse: () => Grade(studentId: student.id, assignmentId: assignment.id),
        );
        row.add(grade.score ?? '');
      }
      final finalGrade = calculator.calculateStudentGrade(student.id);
      row.add(finalGrade?.toStringAsFixed(1) ?? '');
      row.add(finalGrade?.toLetterGrade() ?? '');
      row.add(finalGrade?.toDescription() ?? 'Incomplete');
      rows.add(row);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    await File(filePath).writeAsString(csvData);
  }

  /// Export results to Excel.
  static Future<void> toExcel(
    String filePath,
    List<Student> students,
    List<Assignment> assignments,
    GradeCalculator calculator,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Results'];

    // Header row
    sheet.appendRow([
      TextCellValue('Student ID'),
      TextCellValue('Student Name'),
      ...assignments.map((a) => TextCellValue(a.name)),
      TextCellValue('Final Grade (%)'),
      TextCellValue('Letter Grade'),
      TextCellValue('Status'),
    ]);

    for (var student in students) {
      final row = <CellValue?>[];
      row.add(TextCellValue(student.id));
      row.add(TextCellValue(student.name));
      for (var assignment in assignments) {
        final grade = calculator.grades.firstWhere(
          (g) => g.studentId == student.id && g.assignmentId == assignment.id,
          orElse: () => Grade(studentId: student.id, assignmentId: assignment.id),
        );
        row.add(grade.score != null ? DoubleCellValue(grade.score!) : null);
      }
      final finalGrade = calculator.calculateStudentGrade(student.id);
      row.add(finalGrade != null ? DoubleCellValue(finalGrade) : null);
      row.add(TextCellValue(finalGrade?.toLetterGrade() ?? ''));
      row.add(TextCellValue(finalGrade?.toDescription() ?? 'Incomplete'));
      sheet.appendRow(row);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      await File(filePath).writeAsBytes(bytes);
    }
  }
}
