import 'package:flutter/material.dart';

// ==================== CLASS 01: DATA CLASSES (Minimal) ====================
class Student {
  final String id, name;
  const Student(this.id, this.name);
  @override
  String toString() => name;
}

class Assignment {
  final String name;
  final double max, weight;
  const Assignment(this.name, this.max, this.weight);
}

class Grade {
  final String studentId, assignment;
  final double? score;
  const Grade(this.studentId, this.assignment, this.score);
}

// ==================== CLASS 01: EXTENSION METHODS ====================
extension DoubleExt on double {
  String get f => toStringAsFixed(1);
  String get letter => switch (this) {
    >= 90 => 'A',
    >= 80 => 'B',
    >= 70 => 'C',
    >= 60 => 'D',
    _ => 'F'
  };
  
  Color get color => switch (this) {
    >= 90 => Colors.green,
    >= 80 => Colors.lightGreen,
    >= 70 => Colors.orange,
    >= 60 => Colors.deepOrange,
    _ => Colors.red,
  };
}

// ==================== CLASS 03: GENERIC FUNCTIONS ====================
double? calculateGrade(String studentId, List<Assignment> assignments, List<Grade> grades) {
  final studentGrades = grades.where((g) => g.studentId == studentId).toList();
  if (studentGrades.isEmpty) return null;
  
  double totalWeightedScore = 0.0;
  double totalWeight = 0.0;
  
  for (var assignment in assignments) {
    final grade = studentGrades.firstWhere(
      (g) => g.assignment == assignment.name,
      orElse: () => Grade(studentId, assignment.name, null),
    );
    
    final score = grade.score ?? 0.0;
    totalWeightedScore += score * assignment.weight;
    totalWeight += assignment.weight;
  }
  
  return totalWeight > 0 ? (totalWeightedScore / totalWeight) : null;
}

// ==================== MAIN APP ====================
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
  final List<Student> students = const [
    Student('S001', 'Alice Wonder'),
    Student('S002', 'Bob Builder'),
    Student('S003', 'Charlie Brown'),
  ];
  
  final List<Assignment> assignments = const [
    Assignment('Homework 1', 100, 0.10),
    Assignment('Homework 2', 100, 0.10),
    Assignment('Midterm Exam', 100, 0.30),
    Assignment('Final Project', 100, 0.40),
    Assignment('Participation', 100, 0.10),
  ];
  
  late List<Grade> grades;
  String? selectedStudentId;
  double? finalGrade;
  
  @override
  void initState() {
    super.initState();
    // Initialize sample grades
    grades = [
      // Alice's grades
      const Grade('S001', 'Homework 1', 95),
      const Grade('S001', 'Homework 2', 88),
      const Grade('S001', 'Midterm Exam', 92),
      const Grade('S001', 'Final Project', 95),
      const Grade('S001', 'Participation', 100),
      // Bob's grades
      const Grade('S002', 'Homework 1', 85),
      const Grade('S002', 'Midterm Exam', 78),
      const Grade('S002', 'Final Project', 82),
      // Charlie's grades
      const Grade('S003', 'Homework 1', 100),
      const Grade('S003', 'Homework 2', 95),
      const Grade('S003', 'Midterm Exam', 88),
      const Grade('S003', 'Final Project', 90),
      const Grade('S003', 'Participation', 85),
    ];
    selectedStudentId = students.first.id;
    _calculateGrade();
  }
  
  void _calculateGrade() {
    setState(() {
      finalGrade = calculateGrade(selectedStudentId!, assignments, grades);
    });
  }
  
  void _saveGrade(String assignmentName, double score) {
    setState(() {
      final index = grades.indexWhere(
        (g) => g.studentId == selectedStudentId && g.assignment == assignmentName,
      );
      
      if (index >= 0) {
        // Update existing grade
        grades[index] = Grade(selectedStudentId!, assignmentName, score);
      } else {
        // Add new grade
        grades.add(Grade(selectedStudentId!, assignmentName, score));
      }
      
      _calculateGrade();
    });
  }
  
  void _deleteGrade(String assignmentName) {
    setState(() {
      grades.removeWhere(
        (g) => g.studentId == selectedStudentId && g.assignment == assignmentName,
      );
      _calculateGrade();
    });
  }
  
  double? _getExistingScore(String assignmentName) {
    try {
      return grades.firstWhere(
        (g) => g.studentId == selectedStudentId && g.assignment == assignmentName,
      ).score;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final selectedStudent = students.firstWhere(
      (s) => s.id == selectedStudentId,
      orElse: () => students.first,
    );
    
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
                  final existingScore = _getExistingScore(assignment.name);
                  
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
                                  'Weight: ${(assignment.weight * 100).toInt()}% • Max: ${assignment.max.toInt()}',
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
                                      suffixText: '/${assignment.max.toInt()}',
                                      suffixStyle: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      final score = double.tryParse(value);
                                      if (score != null && score >= 0 && score <= assignment.max) {
                                        _saveGrade(assignment.name, score);
                                      } else if (value.isEmpty) {
                                        _deleteGrade(assignment.name);
                                      }
                                    },
                                  ),
                                ),
                                if (existingScore != null)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    onPressed: () => _deleteGrade(assignment.name),
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
                      finalGrade!.color,
                      finalGrade!.color.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: finalGrade!.color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${finalGrade!.f}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      finalGrade!.letter,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getGradeDescription(finalGrade!),
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
                      final score = _getExistingScore(assignment.name);
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
                                '${score.toInt()}/${assignment.max.toInt()}',
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
  
  String _getGradeDescription(double percentage) {
    if (percentage >= 90) return 'Excellent! 🎉';
    if (percentage >= 80) return 'Good job! 👍';
    if (percentage >= 70) return 'Satisfactory 📚';
    if (percentage >= 60) return 'Needs Improvement ⚠️';
    return 'Failing - Keep Trying! 💪';
  }
}