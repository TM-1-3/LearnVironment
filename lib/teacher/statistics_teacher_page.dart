import 'package:flutter/material.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/subject_cache_service.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '../services/user_cache_service.dart';

class StatisticsTeacherPage extends StatefulWidget {
  const StatisticsTeacherPage({super.key});

  @override
  StatisticsTeacherPageState createState() => StatisticsTeacherPageState();
}

class StatisticsTeacherPageState extends State<StatisticsTeacherPage> {
  bool _isSaved = true;
  SubjectData? _selectedClass;
  List<SubjectData> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = await authService.getUid();
      final userData = await dataService.getUserData(userId: userId);

      if (userData == null) {
        _showErrorDialog("No user is logged in.", "Error");
        return;
      }

      final classList = <SubjectData>[];
      for (final classId in userData.tClasses) {
        final subjectData = await dataService.getSubjectData(subjectId: classId);
        if (subjectData != null) classList.add(subjectData);
      }

      setState(() {
        _classes = classList;
      });
    } catch (e) {
      print("Failed to load Classes: $e");
    }
  }

  Future<void> _refreshClasses() async {
    try {
      final subjectCacheService = Provider.of<SubjectCacheService>(context, listen: false);
      final userCacheService = Provider.of<UserCacheService>(context, listen: false);

      await userCacheService.clearUserCache();
      await subjectCacheService.clearSubjectCache();

      setState(() {
        _classes = [];
        _selectedClass = null;
      });

      await _loadClasses();

    } catch (e) {
      print('[StatisticsTeacherPage] Error refreshing StatisticsPage: $e');
    }
  }

  void _showErrorDialog(String message, String ctx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ctx),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshClasses,  // Calling the refresh method when the user pulls to refresh
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Class Statistics", style: TextStyle(fontSize: 30)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Classes',
                  onPressed: _refreshClasses, // Button to refresh manually
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<SubjectData>(
              value: _selectedClass,
              decoration: const InputDecoration(labelText: 'Class'),
              items: _classes.map((subject) {
                return DropdownMenuItem<SubjectData>(
                  value: subject,
                  child: Text(subject.subjectName),
                );
              }).toList(),
              onChanged: (SubjectData? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedClass = newValue;
                    _isSaved = false;
                  });
                }
              },
            ),
            if (_selectedClass != null) ...[
              const SizedBox(height: 24),
              _buildChartLegend(),
              const SizedBox(height: 16),
              FutureBuilder<Widget>(
                future: _buildBarChart(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    return snapshot.data!;
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
      ),
    );
  }


  Widget _buildChartLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(height: 30),
        Text("✅ Correct answers", style: TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Text("❌ Wrong answers", style: TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.w600)),
        SizedBox(height: 50),
      ],
    );
  }

  Future<Widget> _buildBarChart() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final students = _selectedClass?.students ?? [];

    if (students.isEmpty) {
      return const Center(child: Text("No student data available."));
    }

    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];

    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final studentData = await dataService.getUserData(userId: student['studentId']);
      final studentName = studentData?.name ?? "Unknown";

      final correct = (student['correctCount'] ?? 0) as int;
      final wrong = (student['wrongCount'] ?? 0) as int;

      labels.add(studentName);

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
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < labels.length) {
                      return SideTitleWidget(
                        meta: meta,
                        space: 6,
                        child: Text(labels[index], style: const TextStyle(fontSize: 10)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
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
      final total = math.max<int>(student['correctCount'] ?? 0, student['wrongCount'] ?? 0).toDouble();
      if (total > max) max = total;
    }
    return max + 12;
  }
}
