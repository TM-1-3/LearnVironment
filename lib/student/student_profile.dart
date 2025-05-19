import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class StudentProfilePage extends StatefulWidget {
  final String studentId;

  const StudentProfilePage({super.key, required this.studentId});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  UserData? studentData;
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> weekData = [];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final data = await dataService.getUserData(userId: widget.studentId);
      if (data != null) {
        setState(() {
          studentData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Student not found";
          isLoading = false;
        });
      }

      await _loadWeekData();
    } catch (e) {
      setState(() {
        error = "Error loading student data";
        isLoading = false;
      });
    }
  }

  Future<void> _loadWeekData() async {
    final dataService = Provider.of<DataService>(context, listen: false);

    try {
      print("getting weekdata from ${studentData?.id}");
      final tempWeekData = await dataService.getWeekGameResults(studentId: studentData!.id);

      if (mounted) {
        setState(() {
          weekData = tempWeekData;
        });
      }

      print('[STATS] Loaded weekData: $weekData');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading weekData: $e')),
        );
      }
      print('[STATS ERROR] $e');
    }
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

  String _getShortWeekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1) % 7]; // weekday from 1 (Mon) to 7 (Sun)
  }

  double _getMaxY(List<Map<String, dynamic>> days) {
    double max = 0;
    for (var day in days) {
      final correct = (day['correctCount'] ?? 0) as int;
      final wrong = (day['wrongCount'] ?? 0) as int;
      final total = math.max(correct, wrong).toDouble();
      if (total > max) max = total;
    }
    return max + 5;
  }

  Widget _buildBarChart() {
    if (weekData.isEmpty) {
      return const Center(child: Text("No weekly data available."));
    }

    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];

    for (int i = 0; i < weekData.length; i++) {
      final entry = weekData[i];
      final correct = (entry['correctCount'] ?? 0) as int;
      final wrong = (entry['wrongCount'] ?? 0) as int;

      // Label format: Mon, Tue, etc. or blank if no date
      String label = "";
      if (entry['date'] != null && entry['date'] is DateTime) {
        final date = entry['date'] as DateTime;
        label = _getShortWeekdayName(date.weekday); // custom function below
      }

      labels.add(label);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
                toY: correct.toDouble(), color: Colors.green, width: 12),
            BarChartRodData(
                toY: wrong.toDouble(), color: Colors.red, width: 12),
          ],
          showingTooltipIndicators: [0, 1],
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 6,
                      child: Text(
                          labels[index], style: const TextStyle(fontSize: 12)),
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
          maxY: _getMaxY(weekData),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const CircularProgressIndicator()
                : error != null
                ? Text(error!, style: const TextStyle(color: Colors.red))
                : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Image loading with fallback (optional) ---
                  _buildProfileImage(),

                  const SizedBox(height: 20),
                  Text(
                    studentData!.name,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@${studentData!.username}',
                    style: const TextStyle(
                        fontSize: 26, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    studentData!.email,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),

                  // --- Legend for the bar chart ---
                  _buildChartLegend(),

                  // --- The bar chart itself ---
                  _buildBarChart(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    // Optional: safer image loading with network/asset/file check
    final img = studentData!.img;
    ImageProvider imageProvider;

    if (img.startsWith('http') || img.startsWith('https')) {
      imageProvider = NetworkImage(img);
    } else if (img == 'assets/placeholder.png') {
      imageProvider = AssetImage(img);
    } else {
      // fallback to asset image or you can handle file images here
      imageProvider = AssetImage('assets/placeholder.png');
    }

    return CircleAvatar(
      backgroundImage: imageProvider,
      radius: 100,
    );
  }
}
