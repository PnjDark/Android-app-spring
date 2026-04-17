import 'dart:io';
import 'package:ansicolor/ansicolor.dart';
import '../models/student.dart';
import '../models/assignment.dart';
import '../models/grade.dart';
import '../engine/calculator.dart';
import '../io/file_parser.dart';
import '../io/file_writer.dart';

class CliWizard {
  final AnsiPen _pen = AnsiPen();
  late GradeCalculator _calculator;
  List<Student> _students = [];
  List<Assignment> _assignments = [];
  List<Grade> _grades = [];

  CliWizard();

  void _printHeader(String title) {
    final pen = AnsiPen()..cyan(bold: true);
    print('\n${pen('=' * 60)}');
    print(pen(title.padLeft(30 + title.length ~/ 2)));
    print(pen('=' * 60));
  }

  void _printSuccess(String msg) {
    final pen = AnsiPen()..green(bold: true);
    print(pen('✓ $msg'));
  }

  void _printError(String msg) {
    final pen = AnsiPen()..red(bold: true);
    print(pen('✗ $msg'));
  }

  void _printInfo(String msg) {
    final pen = AnsiPen()..yellow(bold: true);
    print(pen('ℹ $msg'));
  }

  String? _input(String prompt, {bool required = true}) {
    final pen = AnsiPen()..yellow(bold: true);
    stdout.write(pen(prompt));
    final input = stdin.readLineSync()?.trim();
    if (required && (input == null || input.isEmpty)) {
      _printError('This field is required');
      return _input(prompt, required: required);
    }
    return input;
  }

  /// Main entry point.
  Future<void> run() async {
    _printHeader('🎓 GRADE CALCULATOR - FILE PROCESSING');

    // Choose data source
    print('\nChoose data source:');
    print('  1. Upload file (CSV/Excel)');
    print('  2. Manual entry');
    print('  0. Exit');
    final choice = _input('Enter choice (1/2/0): ', required: true);
    if (choice == '0') {
      print('\nGoodbye!');
      return;
    }

    if (choice == '1') {
      await _processFromFile();
    } else if (choice == '2') {
      await _manualEntry();
    } else {
      _printError('Invalid choice');
      await run();
      return;
    }

    // After data is loaded, calculate and display results
    _calculator = GradeCalculator(
      students: _students,
      assignments: _assignments,
      grades: _grades,
    );
    _showResults();

    // Ask if user wants to export
    final exportChoice = _input('\nExport results? (y/n): ', required: false)?.toLowerCase();
    if (exportChoice == 'y') {
      await _exportResults();
    }

    _printHeader('✨ DONE!');
  }

  Future<void> _processFromFile() async {
    _printHeader('📂 FILE UPLOAD');
    final filePath = _input('Enter file path: ', required: true);
    if (filePath == null) return;

    if (!File(filePath).existsSync()) {
      _printError('File not found');
      return;
    }

    try {
      final ext = filePath.split('.').last.toLowerCase();
      ParsedData parsed;
      if (ext == 'csv') {
        parsed = await FileParser.parseCsv(filePath);
      } else if (ext == 'xlsx' || ext == 'xls') {
        parsed = await FileParser.parseExcel(filePath);
      } else {
        _printError('Unsupported file format. Please use .csv or .xlsx');
        return;
      }

      _students = parsed.students;
      _assignments = parsed.assignments;
      _grades = parsed.grades;

      _printSuccess('Loaded ${_students.length} students, ${_assignments.length} assignments, ${_grades.length} grades');
    } catch (e) {
      _printError('Failed to parse file: $e');
    }
  }

  Future<void> _manualEntry() async {
    _printHeader('✏️ MANUAL ENTRY');

    // Students
    while (true) {
      print('\n--- Add Student ---');
      final name = _input('Name: ');
      if (name == null) break;
      final id = _input('ID (e.g., S001): ') ?? 'S${_students.length + 1}'.padLeft(4, '0');
      final email = _input('Email (optional, Enter to skip): ', required: false);
      final year = _inputInt('Enrollment year (2024): ', min: 2000, max: 2030) ?? 2024;
      _students.add(Student(
        id: id,
        name: name,
        email: email?.isEmpty ?? true ? null : email,
        enrollmentYear: year,
      ));
      _printSuccess('Added $name ($id)');
      final more = _input('Add another? (y/n): ', required: false)?.toLowerCase();
      if (more != 'y') break;
    }

    // Assignments
    var totalWeight = 0.0;
    while (totalWeight < 0.99) {
      print('\n--- Add Assignment ---');
      final name = _input('Name: ');
      if (name == null) break;
      final maxScore = _inputDouble('Max score (100): ', min: 1) ?? 100;
      final weightPercent = _inputDouble('Weight % (0-100): ', min: 0, max: 100 - totalWeight * 100);
      if (weightPercent == null) break;
      final weight = weightPercent / 100;
      totalWeight += weight;
      _assignments.add(Assignment(
        id: 'A${_assignments.length + 1}'.padLeft(4, '0'),
        name: name,
        maxScore: maxScore,
        weight: weight,
      ));
      _printSuccess('Added $name (${weightPercent}%)');
      if (totalWeight < 0.99) {
        final more = _input('Add another? (y/n): ', required: false)?.toLowerCase();
        if (more != 'y') break;
      }
    }

    // Normalize weights if needed
    if (totalWeight != 1.0) {
      _printInfo('Total weight is ${(totalWeight * 100).toStringAsFixed(1)}%. Normalizing...');
      final factor = 1.0 / totalWeight;
      for (var i = 0; i < _assignments.length; i++) {
        _assignments[i] = Assignment(
          id: _assignments[i].id,
          name: _assignments[i].name,
          maxScore: _assignments[i].maxScore,
          weight: _assignments[i].weight * factor,
        );
      }
      _printSuccess('Weights normalized to 100%');
    }

    // Grades
    for (var student in _students) {
      print('\n--- Grades for ${student.name} (${student.id}) ---');
      for (var assignment in _assignments) {
        final existing = _grades.firstWhere(
          (g) => g.studentId == student.id && g.assignmentId == assignment.id,
          orElse: () => Grade(studentId: student.id, assignmentId: assignment.id),
        );
        final prompt = '  ${assignment.name} (${assignment.weightPercent}%) [0-${assignment.maxScore}]'
            '${existing.score != null ? ' current: ${existing.score}' : ''}: ';
        final score = _inputDouble(prompt, min: 0, max: assignment.maxScore);
        if (score != null) {
          final index = _grades.indexWhere(
            (g) => g.studentId == student.id && g.assignmentId == assignment.id,
          );
          if (index >= 0) {
            _grades[index] = Grade(
              studentId: student.id,
              assignmentId: assignment.id,
              score: score,
              submissionDate: DateTime.now(),
            );
          } else {
            _grades.add(Grade(
              studentId: student.id,
              assignmentId: assignment.id,
              score: score,
              submissionDate: DateTime.now(),
            ));
          }
        }
      }
    }
  }

  void _showResults() {
    _printHeader('📊 RESULTS');

    print('\n${'Student'.padRight(20)} ${'Grade'.padRight(10)} ${'Letter'.padRight(8)} Status');
    print('-' * 60);
    for (var student in _students) {
      final grade = _calculator.calculateStudentGrade(student.id);
      final gradeStr = grade?.toStringAsFixed(1) ?? 'N/A';
      final letter = grade?.toLetterGrade() ?? 'N/A';
      final status = grade?.toDescription() ?? 'Incomplete';
      print('${student.name.padRight(20)} ${gradeStr.padRight(10)} ${letter.padRight(8)} $status');
    }

    final stats = _calculator.getClassStatistics();
    print('\n📈 CLASS STATISTICS:');
    print('  • Average: ${stats['average']?.toStringAsFixed(1)}%');
    print('  • Highest: ${stats['highest']?.toStringAsFixed(1)}%');
    print('  • Lowest: ${stats['lowest']?.toStringAsFixed(1)}%');
    print('  • Students: ${stats['count']}/${_students.length} complete');

    print('\n📊 GRADE DISTRIBUTION:');
    final dist = stats['distribution'] as Map;
    print('  A: ${'█' * (dist['A'] as int)} (${dist['A']})');
    print('  B: ${'█' * (dist['B'] as int)} (${dist['B']})');
    print('  C: ${'█' * (dist['C'] as int)} (${dist['C']})');
    print('  D: ${'█' * (dist['D'] as int)} (${dist['D']})');
    print('  F: ${'█' * (dist['F'] as int)} (${dist['F']})');
  }

  Future<void> _exportResults() async {
    _printHeader('💾 EXPORT');
    final format = _input('Export format (csv/excel): ', required: false)?.toLowerCase();
    if (format != 'csv' && format != 'excel') {
      _printError('Invalid format');
      return;
    }
    final fileName = _input('File name (e.g., results.$format): ', required: false) ?? 'results.$format';
    try {
      if (format == 'csv') {
        await FileWriter.toCsv(fileName, _students, _assignments, _calculator);
      } else {
        await FileWriter.toExcel(fileName, _students, _assignments, _calculator);
      }
      _printSuccess('Exported to $fileName');
    } catch (e) {
      _printError('Export failed: $e');
    }
  }

  // Helper input methods
  double? _inputDouble(String prompt, {double? min, double? max}) {
    final input = _input(prompt);
    if (input == null) return null;
    try {
      final value = double.parse(input);
      if (min != null && value < min) {
        _printError('Value must be at least $min');
        return _inputDouble(prompt, min: min, max: max);
      }
      if (max != null && value > max) {
        _printError('Value must be at most $max');
        return _inputDouble(prompt, min: min, max: max);
      }
      return value;
    } catch (_) {
      _printError('Please enter a valid number');
      return _inputDouble(prompt, min: min, max: max);
    }
  }

  int? _inputInt(String prompt, {int? min, int? max}) {
    final input = _input(prompt);
    if (input == null) return null;
    try {
      final value = int.parse(input);
      if (min != null && value < min) {
        _printError('Value must be at least $min');
        return _inputInt(prompt, min: min, max: max);
      }
      if (max != null && value > max) {
        _printError('Value must be at most $max');
        return _inputInt(prompt, min: min, max: max);
      }
      return value;
    } catch (_) {
      _printError('Please enter a valid number');
      return _inputInt(prompt, min: min, max: max);
    }
  }
}
