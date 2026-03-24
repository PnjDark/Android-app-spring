import 'package:flutter/material.dart';
import 'models.dart';
import 'logic.dart';

void main() {
  runApp(StudentGradeApp());
}

class StudentGradeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Grade Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: GradeManagementScreen(),
    );
  }
}

class GradeManagementScreen extends StatefulWidget {
  @override
  _GradeManagementScreenState createState() => _GradeManagementScreenState();
}

class _GradeManagementScreenState extends State<GradeManagementScreen> {
  // Data
  final List<Student> students = [
    Student(id: 'S001', name: 'Alice Wonder', email: 'alice@email.com', enrollmentYear: 2024),
    Student(id: 'S002', name: 'Bob Builder', email: 'bob@email.com', enrollmentYear: 2024),
    Student(id: 'S003', name: 'Charlie Brown', enrollmentYear: 2023),
  ];
  
  final List<Assignment> assignments = [
    Assignment(id: 'A001', name: 'Homework 1', maxScore: 100, weight: 0.10),
    Assignment(id: 'A002', name: 'Homework 2', maxScore: 100, weight: 0.10),
    Assignment(id: 'A003', name: 'Midterm Exam', maxScore: 100, weight: 0.30),
    Assignment(id: 'A004', name: 'Final Project', maxScore: 100, weight: 0.40),
    Assignment(id: 'A005', name: 'Participation', maxScore: 100, weight: 0.10),
  ];
  
  List<Grade> grades = [
    Grade(studentId: 'S001', assignmentId: 'A001', score: 95.0),
    Grade(studentId: 'S001', assignmentId: 'A002', score: 88.0),
    Grade(studentId: 'S001', assignmentId: 'A003', score: 92.0),
    Grade(studentId: 'S001', assignmentId: 'A004', score: 95.0),
    Grade(studentId: 'S001', assignmentId: 'A005', score: 100.0),
    Grade(studentId: 'S002', assignmentId: 'A001', score: 85.0),
    Grade(studentId: 'S002', assignmentId: 'A003', score: 78.0),
    Grade(studentId: 'S002', assignmentId: 'A004', score: 82.0),
    // Bob missing Homework 2 and Participation
  ];
  
  // UI State
  String? selectedStudentId;
  String? selectedAssignmentId;
  double? enteredScore;
  String? errorMessage;
  String? successMessage;
  double? finalPercentage;
  
  Color getGradeColor(double percentage) {
  if (percentage >= 90) return Color(0xFF2E7D32);  // Dark Green
  if (percentage >= 80) return Color(0xFF558B2F);  // Light Green
  if (percentage >= 70) return Color(0xFFF57C00);  // Orange
  if (percentage >= 60) return Color(0xFFE65100);  // Deep Orange
  return Color(0xFFC62828);  // Red
}


  // Controllers
  final TextEditingController scoreController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Set default selections
    if (students.isNotEmpty) selectedStudentId = students[0].id;
    if (assignments.isNotEmpty) selectedAssignmentId = assignments[0].id;
  }
  
  @override
  void dispose() {
    scoreController.dispose();
    super.dispose();
  }
  
  void loadExistingScore() {
    if (selectedStudentId != null && selectedAssignmentId != null) {
      final existingScore = getExistingScore(
        studentId: selectedStudentId!,
        assignmentId: selectedAssignmentId!,
        grades: grades,
      );
      
      setState(() {
        enteredScore = existingScore;
        scoreController.text = existingScore?.toString() ?? '';
      });
    }
  }
  
  void saveGrade() {
    // Validation
    if (selectedStudentId == null) {
      setState(() {
        errorMessage = 'Please select a student';
        successMessage = null;
      });
      return;
    }
    
    if (selectedAssignmentId == null) {
      setState(() {
        errorMessage = 'Please select an assignment';
        successMessage = null;
      });
      return;
    }
    
    if (enteredScore == null) {
      setState(() {
        errorMessage = 'Please enter a score';
        successMessage = null;
      });
      return;
    }
    
    // Get assignment max score
    final assignment = assignments.firstWhere(
      (a) => a.id == selectedAssignmentId,
    );
    
    if (enteredScore! < 0 || enteredScore! > assignment.maxScore) {
      setState(() {
        errorMessage = 'Score must be between 0 and ${assignment.maxScore}';
        successMessage = null;
      });
      return;
    }
    
    // Save or update grade
    saveOrUpdateGrade(
      studentId: selectedStudentId!,
      assignmentId: selectedAssignmentId!,
      score: enteredScore!,
      grades: grades,
    );
    
    // Recalculate final grade
    finalPercentage = calculateFinalGrade(
      studentId: selectedStudentId!,
      assignments: assignments,
      grades: grades,
    );
    
    // Show success message
    final student = students.firstWhere((s) => s.id == selectedStudentId);
    final assignmentName = assignments.firstWhere((a) => a.id == selectedAssignmentId).name;
    
    setState(() {
      errorMessage = null;
      successMessage = '✅ Saved ${enteredScore}/${assignment.maxScore} for ${student.name} - $assignmentName';
    });
    
    // Clear success message after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          successMessage = null;
        });
      }
    });
  }
  
  void deleteGrade() {
    if (selectedStudentId == null || selectedAssignmentId == null) {
      setState(() {
        errorMessage = 'Please select student and assignment';
      });
      return;
    }
    
    final index = grades.indexWhere(
      (g) => g.studentId == selectedStudentId && g.assignmentId == selectedAssignmentId,
    );
    
    if (index >= 0) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Grade'),
          content: Text('Are you sure you want to delete this grade?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  grades.removeAt(index);
                  enteredScore = null;
                  scoreController.clear();
                  
                  // Recalculate
                  finalPercentage = calculateFinalGrade(
                    studentId: selectedStudentId!,
                    assignments: assignments,
                    grades: grades,
                  );
                  
                  errorMessage = null;
                  successMessage = '🗑️ Grade deleted successfully';
                });
                Navigator.pop(context);
                
                // Clear success message after 3 seconds
                Future.delayed(Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      successMessage = null;
                    });
                  }
                });
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        errorMessage = 'No grade exists to delete';
      });
    }
  }
  
  void resetForm() {
    setState(() {
      enteredScore = null;
      scoreController.clear();
      errorMessage = null;
      successMessage = null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final selectedStudent = students.firstWhere(
      (s) => s.id == selectedStudentId,
      orElse: () => students.first,
    );
    
    final selectedAssignment = assignments.firstWhere(
      (a) => a.id == selectedAssignmentId,
      orElse: () => assignments.first,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text('📝 Grade Manager'),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetForm,
            tooltip: 'Reset form',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Enter Student Grades',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Select student and assignment, then enter score',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            
            // Student Dropdown
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                hint: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Select Student'),
                ),
                value: selectedStudentId,
                isExpanded: true,
                underline: SizedBox(),
                items: students.map((student) {
                  return DropdownMenuItem(
                    value: student.id,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${student.name} (${student.id})'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStudentId = value;
                    loadExistingScore();
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            
            // Assignment Dropdown
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                hint: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Select Assignment'),
                ),
                value: selectedAssignmentId,
                isExpanded: true,
                underline: SizedBox(),
                items: assignments.map((assignment) {
                  return DropdownMenuItem(
                    value: assignment.id,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(assignment.name),
                          Text(
                            'Weight: ${(assignment.weight * 100).toInt()}% | Max: ${assignment.maxScore}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAssignmentId = value;
                    loadExistingScore();
                  });
                },
              ),
            ),
            SizedBox(height: 24),
            
            // Score Input
            TextField(
              controller: scoreController,
              decoration: InputDecoration(
                labelText: 'Enter Score (0 - ${selectedAssignment.maxScore})',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.grade),
                helperText: enteredScore != null 
                    ? 'Current score: $enteredScore' 
                    : 'No grade entered yet',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  enteredScore = double.tryParse(value);
                  if (enteredScore != null) {
                    errorMessage = null;
                  }
                });
              },
            ),
            SizedBox(height: 16),
            
            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: saveGrade,
                    icon: Icon(Icons.save),
                    label: Text('Save Grade'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.green.shade700,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: deleteGrade,
                    icon: Icon(Icons.delete),
                    label: Text('Delete Grade'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Messages
            if (errorMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            
            if (successMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        successMessage!,
                        style: TextStyle(color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: 24),
            
            // Divider
            Divider(height: 32),
            
            // Results Card
            Text(
              '📊 RESULTS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Student Info
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.person, color: Colors.blue),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedStudent.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ID: ${selectedStudent.id}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    
                    // Grade Display
                    if (finalPercentage != null) ...[
                      Text(
                        'Final Grade',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${finalPercentage!.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: getGradeColor(finalPercentage!),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: getGradeColor(finalPercentage!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          toLetterGrade(finalPercentage!),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: getGradeColor(finalPercentage!),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        getGradeDescription(finalPercentage!),
                        style: TextStyle(
                          fontSize: 16,
                          color: getGradeColor(finalPercentage!),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No grades available for this student',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Progress Summary
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Progress Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...assignments.map((assignment) {
                      final existingGrade = getExistingScore(
                        studentId: selectedStudent.id,
                        assignmentId: assignment.id,
                        grades: grades,
                      );
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              existingGrade != null 
                                  ? Icons.check_circle 
                                  : Icons.circle_outlined,
                              size: 16,
                              color: existingGrade != null 
                                  ? Colors.green 
                                  : Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(assignment.name),
                            ),
                            if (existingGrade != null)
                              Text(
                                '${existingGrade}/${assignment.maxScore}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              )
                            else
                              Text(
                                'Not graded',
                                style: TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}