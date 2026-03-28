import 'package:flutter/material.dart';
import 'models/student.dart';
import 'models/assignment.dart';
import 'models/grade.dart';
import 'engine/calculator.dart';

void main() => runApp(const GradeApp());

class GradeApp extends StatelessWidget {
  const GradeApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Calculator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
  // ==================== SAMPLE DATA ====================
  final List<Student> students = [
    Student(id: 'S001', name: 'Alice Wonder', enrollmentYear: 2024),
    Student(id: 'S002', name: 'Bob Builder', enrollmentYear: 2024),
    Student(id: 'S003', name: 'Charlie Brown', enrollmentYear: 2024),
  ];
  
  final List<Assignment> assignments = [
    Assignment(id: 'A001', name: 'Homework 1', maxScore: 100, weight: 0.10),
    Assignment(id: 'A002', name: 'Homework 2', maxScore: 100, weight: 0.10),
    Assignment(id: 'A003', name: 'Midterm Exam', maxScore: 100, weight: 0.30),
    Assignment(id: 'A004', name: 'Final Project', maxScore: 100, weight: 0.40),
    Assignment(id: 'A005', name: 'Participation', maxScore: 100, weight: 0.10),
  ];
  
  late List<Grade> grades;
  String? selectedStudentId;
  double? finalGrade;
  late GradeCalculator _calculator;
  
  @override
  void initState() {
    super.initState();
    // Initialize sample grades
    grades = [
      // Alice's grades
      Grade(studentId: 'S001', assignmentId: 'A001', score: 95),
      Grade(studentId: 'S001', assignmentId: 'A002', score: 88),
      Grade(studentId: 'S001', assignmentId: 'A003', score: 92),
      Grade(studentId: 'S001', assignmentId: 'A004', score: 95),
      Grade(studentId: 'S001', assignmentId: 'A005', score: 100),
      // Bob's grades
      Grade(studentId: 'S002', assignmentId: 'A001', score: 85),
      Grade(studentId: 'S002', assignmentId: 'A003', score: 78),
      Grade(studentId: 'S002', assignmentId: 'A004', score: 82),
      // Charlie's grades
      Grade(studentId: 'S003', assignmentId: 'A001', score: 100),
      Grade(studentId: 'S003', assignmentId: 'A002', score: 95),
      Grade(studentId: 'S003', assignmentId: 'A003', score: 88),
      Grade(studentId: 'S003', assignmentId: 'A004', score: 90),
      Grade(studentId: 'S003', assignmentId: 'A005', score: 85),
    ];
    selectedStudentId = students.first.id;
    _updateCalculator();
  }
  
  void _updateCalculator() {
    _calculator = GradeCalculator(
      students: students,
      assignments: assignments,
      grades: grades,
    );
    _calculateGrade();
  }

  void _calculateGrade() {
    setState(() {
      finalGrade = _calculator.calculateStudentGrade(selectedStudentId!);
    });
  }
  
  void _saveGrade(String assignmentId, double score) {
    setState(() {
      final index = grades.indexWhere(
        (g) => g.studentId == selectedStudentId && g.assignmentId == assignmentId,
      );
      
      if (index >= 0) {
        // Update existing grade
        grades[index] = Grade(
          studentId: selectedStudentId!,
          assignmentId: assignmentId,
          score: score,
        );
      } else {
        // Add new grade
        grades.add(Grade(
          studentId: selectedStudentId!,
          assignmentId: assignmentId,
          score: score,
        ));
      }
      
      _updateCalculator();
    });
  }
  
  void _deleteGrade(String assignmentId) {
    setState(() {
      grades.removeWhere(
        (g) => g.studentId == selectedStudentId && g.assignmentId == assignmentId,
      );
      _updateCalculator();
    });
  }
  
  double? _getExistingScore(String assignmentId) {
    try {
      return grades.firstWhere(
        (g) => g.studentId == selectedStudentId && g.assignmentId == assignmentId,
      ).score;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Grade Calculator'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: selectedStudentId,
                isExpanded: true,
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                items: students.map((student) {
                  return DropdownMenuItem(
                    value: student.id,
                    child: Text(
                      student.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStudentId = value;
                    _calculateGrade();
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            
            // Assignments List with Grade Input
            Expanded(
              child: ListView.builder(
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final assignment = assignments[index];
                  final existingScore = _getExistingScore(assignment.id);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  assignment.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Weight: ${(assignment.weight * 100).toInt()}% • Max: ${assignment.maxScore.toInt()}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: existingScore?.toString() ?? '0',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                      suffixText: '/${assignment.maxScore.toInt()}',
                                      suffixStyle: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      final score = double.tryParse(value);
                                      if (score != null && score >= 0 && score <= assignment.maxScore) {
                                        _saveGrade(assignment.id, score);
                                      } else if (value.isEmpty) {
                                        _deleteGrade(assignment.id);
                                      }
                                    },
                                  ),
                                ),
                                if (existingScore != null)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    onPressed: () => _deleteGrade(assignment.id),
                                    tooltip: 'Delete grade',
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Result Display
            if (finalGrade != null) ...[
              const Divider(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getGradeColor(finalGrade!),
                      _getGradeColor(finalGrade!).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getGradeColor(finalGrade!).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${finalGrade!.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      finalGrade!.toLetterGrade(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      finalGrade!.toDescription(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Progress Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...assignments.map((assignment) {
                      final score = _getExistingScore(assignment.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              score != null ? Icons.check_circle : Icons.circle_outlined,
                              size: 16,
                              color: score != null ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                assignment.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            if (score != null)
                              Text(
                                '${score.toInt()}/${assignment.maxScore.toInt()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              )
                            else
                              Text(
                                'Not graded',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.deepOrange;
    return Colors.red;
  }
}
