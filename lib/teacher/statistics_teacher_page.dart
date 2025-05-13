import 'package:flutter/material.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class StatisticsTeacherPage extends StatefulWidget {
  StatisticsTeacherPage({super.key});

  @override
  StatisticsTeacherPageState createState() => StatisticsTeacherPageState();
}

class StatisticsTeacherPageState extends State<StatisticsTeacherPage> {
  bool _isSaved = true;
  late TextEditingController titleController;
  late String _selectedClass;
  late List<String> _classes = [];
  late SubjectData? _currentClass = null;

  @override
  void initState() {
    super.initState();
    _selectedClass = '';
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      DataService dataService = Provider.of<DataService>(context, listen: false);
      AuthService authService = Provider.of<AuthService>(context, listen: false);
      UserData? userData = await dataService.getUserData(userId: await authService.getUid());
      if (userData == null) {
        _showErrorDialog("No user is logged in.", "Error");
        return;
      }
      setState(() {
        _classes = userData.classes;
      });
    } catch (e) {
      print("Failed to load Classes");
      rethrow;
    }
  }

  Future<void> _loadClass(String selectedClass) async {
    DataService dataService = Provider.of<DataService>(context, listen: false);
    final newClass = await dataService.getSubjectData(subjectId: selectedClass);

    setState(() {
      _currentClass = newClass;
    });
  }

  void _showErrorDialog(String message, String ctx) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ctx),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: Text("Class Statistics", style: TextStyle(fontSize: 30),)),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedClass.isNotEmpty ? _selectedClass : null,
            decoration: const InputDecoration(labelText: 'Class'),
            items: _classes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedClass = newValue;
                  _isSaved = false;
                });
                _loadClass(_selectedClass);
              }
            },
          ),
          if (_currentClass != null) ...[
            const SizedBox(height: 24),
            _buildChartLegend(),
            const SizedBox(height: 16),
            FutureBuilder<Widget>(
              future: _buildBarChart(), // Using FutureBuilder to handle the future
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator()); // Loading indicator
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData) {
                  return snapshot.data!; // Display the bar chart once it's ready
                } else {
                  return const Center(child: Text("No data available."));
                }
              },
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: Text("Select a class to see statistics")),
            ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(height: 30),
        Text(
          "✅ Correct answers",
          style: TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6),
        Text(
          "❌ Wrong answers",
          style: TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 50),
      ],
    );
  }

  Future<Widget> _buildBarChart() async {
    DataService dataService = Provider.of<DataService>(context, listen: false);

    final students = _currentClass!.students;
    if (students.isEmpty) {
      return const Center(child: Text("No student data available."));
    }

    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];

    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final studentData = await dataService.getUserData(userId: student['studentId']);

      final correct = (student['correctCount'] ?? 0) as int;
      final wrong = (student['wrongCount'] ?? 0) as int;
      final studentName = studentData?.name;

      labels.add(studentName!);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: correct.toDouble(), color: Colors.green, width: 8),
            BarChartRodData(toY: wrong.toDouble(), color: Colors.red, width: 8),
          ],
          showingTooltipIndicators: [0, 1],
        ),
      );
    }

    // Estimate total width: each group ~48px (2 bars x 8 + spacing), plus extra
    final chartWidth = students.length * 100.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: chartWidth,
        height: 300,
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < labels.length) {
                      return SideTitleWidget(
                        meta: meta,
                        space: 6,
                        child: Text(
                          labels[index],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 60,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: true),
            groupsSpace: 12,
            maxY: _getMaxY(students),
          ),
        ),
      ),
    );
  }

  double _getMaxY(List<Map<String, dynamic>> students) {
    double max = 0;
    for (var student in students) {
      double total = math.max<int>(student['correctCount'], student['wrongCount']).toDouble();
      if (total > max) max = total;
    }
    return max + 12; // extra space on the axis
  }
}
