import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'models/student.dart';
import 'models/assignment.dart';
import 'models/grade.dart';
import 'engine/calculator.dart';
import 'io/file_parser.dart';
import 'io/file_writer.dart';

void main() => runApp(const GradeApp());

class GradeApp extends StatelessWidget {
  const GradeApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const GradeScreen(),
    );
  }
}

class GradeScreen extends StatefulWidget {
  const GradeScreen({super.key});
  
  @override
  State<GradeScreen> createState() => _GradeScreenState();
}

class _GradeScreenState extends State<GradeScreen> {
  List<Student> students = [
    Student(id: 'S001', name: 'Alice Wonder', enrollmentYear: 2024),
    Student(id: 'S002', name: 'Bob Builder', enrollmentYear: 2024),
    Student(id: 'S003', name: 'Charlie Brown', enrollmentYear: 2024),
  ];
  
  List<Assignment> assignments = [
    Assignment(id: 'A001', name: 'Homework 1', maxScore: 100, weight: 0.10),
    Assignment(id: 'A002', name: 'Homework 2', maxScore: 100, weight: 0.10),
    Assignment(id: 'A003', name: 'Midterm Exam', maxScore: 100, weight: 0.30),
    Assignment(id: 'A004', name: 'Final Project', maxScore: 100, weight: 0.40),
    Assignment(id: 'A005', name: 'Participation', maxScore: 100, weight: 0.10),
  ];
  
  List<Grade> grades = [];
  String? selectedStudentId;
  late GradeCalculator _calculator;

  @override
  void initState() {
    super.initState();
    _loadSampleGrades();
    if (students.isNotEmpty) selectedStudentId = students.first.id;
    _updateCalculator();
  }

  void _loadSampleGrades() {
    grades = [
      Grade(studentId: 'S001', assignmentId: 'A001', score: 95),
      Grade(studentId: 'S001', assignmentId: 'A002', score: 88),
      Grade(studentId: 'S001', assignmentId: 'A003', score: 92),
      Grade(studentId: 'S001', assignmentId: 'A004', score: 95),
      Grade(studentId: 'S001', assignmentId: 'A005', score: 100),
      Grade(studentId: 'S002', assignmentId: 'A001', score: 85),
      Grade(studentId: 'S002', assignmentId: 'A003', score: 78),
      Grade(studentId: 'S002', assignmentId: 'A004', score: 82),
    ];
  }
  
  void _updateCalculator() {
    _calculator = GradeCalculator(
      students: students,
      assignments: assignments,
      grades: grades,
    );
  }

  Future<void> _importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
    );

    if (result != null) {
      final path = result.files.single.path!;
      final ext = path.split('.').last.toLowerCase();

      try {
        ParsedData parsed;
        if (ext == 'csv') {
          parsed = await FileParser.parseCsv(path);
        } else {
          parsed = await FileParser.parseExcel(path);
        }

        setState(() {
          students = parsed.students;
          assignments = parsed.assignments;
          grades = parsed.grades;
          if (students.isNotEmpty) selectedStudentId = students.first.id;
          _updateCalculator();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${students.length} students')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import: $e')),
        );
      }
    }
  }

  Future<void> _exportFile() async {
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Results',
      fileName: 'results.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    try {
      await FileWriter.toCsv(outputPath, students, assignments, _calculator);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to $outputPath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export: $e')),
      );
    }
    }

  void _saveGrade(String assignmentId, double score) {
    setState(() {
      final index = grades.indexWhere(
        (g) => g.studentId == selectedStudentId && g.assignmentId == assignmentId,
      );
      
      if (index >= 0) {
        grades[index] = Grade(studentId: selectedStudentId!, assignmentId: assignmentId, score: score);
      } else {
        grades.add(Grade(studentId: selectedStudentId!, assignmentId: assignmentId, score: score));
      }
      _updateCalculator();
    });
  }

  void _deleteGrade(String assignmentId) {
    setState(() {
      grades.removeWhere((g) => g.studentId == selectedStudentId && g.assignmentId == assignmentId);
      _updateCalculator();
    });
  }

  double? _getExistingScore(String assignmentId) {
    try {
      return grades.firstWhere((g) => g.studentId == selectedStudentId && g.assignmentId == assignmentId).score;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalGrade = selectedStudentId != null ? _calculator.calculateStudentGrade(selectedStudentId!) : null;
    final stats = _calculator.getClassStatistics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Desktop Grade Manager'),
        actions: [
          IconButton(icon: const Icon(Icons.upload_file), onPressed: _importFile, tooltip: 'Import CSV/Excel'),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportFile, tooltip: 'Export CSV'),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar / Student List
          SizedBox(
            width: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Students (${students.length})', style: Theme.of(context).textTheme.titleLarge),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final grade = _calculator.calculateStudentGrade(student.id);
                      return ListTile(
                        title: Text(student.name),
                        subtitle: Text(student.id),
                        trailing: Text(grade != null ? '${grade.toStringAsFixed(1)}%' : '-'),
                        selected: selectedStudentId == student.id,
                        onTap: () => setState(() => selectedStudentId = student.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedStudentId != null) ...[
                    _buildStudentHeader(students.firstWhere((s) => s.id == selectedStudentId), finalGrade),
                    const SizedBox(height: 24),
                    _buildAssignmentsList(),
                    const SizedBox(height: 32),
                    _buildStatsCard(stats),
                  ] else
                    const Center(child: Text('Select a student to view grades')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentHeader(Student student, double? finalGrade) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: Theme.of(context).textTheme.headlineSmall),
                  Text('ID: ${student.id} | Year: ${student.enrollmentYear}'),
                ],
              ),
            ),
            if (finalGrade != null) ...[
              Column(
                children: [
                  Text('${finalGrade.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  Text(finalGrade.toLetterGrade(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Assignments', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...assignments.map((assignment) {
          final score = _getExistingScore(assignment.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(assignment.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                  Text('Weight: ${(assignment.weight * 100).toInt()}%'),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: score?.toString() ?? '0',
                        suffixText: '/${assignment.maxScore.toInt()}',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      onSubmitted: (val) {
                        final s = double.tryParse(val);
                        if (s != null) _saveGrade(assignment.id, s);
                      },
                    ),
                  ),
                  if (score != null)
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteGrade(assignment.id)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    final dist = stats['distribution'] as Map;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📈 Class Statistics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.spaceAround,
              children: [
                _buildStatItem('Average', '${(stats['average'] as double).toStringAsFixed(1)}%'),
                _buildStatItem('Highest', '${(stats['highest'] as double).toStringAsFixed(1)}%'),
                _buildStatItem('Lowest', '${(stats['lowest'] as double).toStringAsFixed(1)}%'),
                _buildStatItem('Students', '${stats['count']}/${students.length}'),
              ],
            ),
            const Divider(height: 32),
            Text('Grade Distribution', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...['A', 'B', 'C', 'D', 'F'].map((l) {
              final count = dist[l] ?? 0;
              final percent = stats['count'] > 0 ? count / stats['count'] : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 20, child: Text(l)),
                    Expanded(child: LinearProgressIndicator(value: percent as double)),
                    const SizedBox(width: 12),
                    Text('$count'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
