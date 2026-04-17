import 'package:test/test.dart';
import 'dart:io';
import '../lib/io/file_parser.dart';

void main() {
  test('parse CSV with sample data', () async {
    final file = File('test/sample.csv');
    await file.writeAsString("Type,ID,Name,Email,EnrollmentYear\r\nStudent,S001,Alice,alice@email.com,2024\r\nType,ID,Name,MaxScore,Weight,DueDate\r\nAssignment,A001,HW1,100,0.10,2026-02-01\r\nType,StudentID,AssignmentID,Score,SubmissionDate,Comments\r\nGrade,S001,A001,95,2026-02-01,Good");
    final parsed = await FileParser.parseCsv(file.path);
    expect(parsed.students.length, 1);
    expect(parsed.assignments.length, 1);
    expect(parsed.grades.length, 1);
    await file.delete();
  });
}
