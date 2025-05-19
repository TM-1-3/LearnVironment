import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class StudentStatsPage extends StatefulWidget {
  const StudentStatsPage({super.key});

  @override
  StudentStatsPageState createState() => StudentStatsPageState();
}

class StudentStatsPageState extends State<StudentStatsPage> {
  List<Map<String, dynamic>> games = [];
  List<Map<String, dynamic>> weekData = [];

  @override
  void initState() {
    super.initState();
    _loadGames();
    _loadWeekData();
  }

  Future<void> _loadGames() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final uid = await authService.getUid();
      final fetchedGames = await dataService.getPlayedGames(userId: uid);

      setState(() {
        games = fetchedGames;
      });

      if (fetchedGames.isEmpty) {
        print('[STATS] No games played yet.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading games: $e')),
        );
      }
      print('[STATS ERROR] $e');
    }
  }

  Future<void> _loadWeekData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final uid = await authService.getUid();

    try {
      final tempWeekData = await dataService.getWeekGameResults(studentId: uid);

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

  Future<void> _refreshGames() async {
    await _loadGames();
    await _loadWeekData();
  }

  Future<void> _loadGame(String gameId) async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final gameData = await dataService.getGameData(gameId: gameId);

      if (gameData != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamesInitialScreen(gameData: gameData),
          ),
        );
      } else {
        throw 'Game data not found';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game: $e')),
        );
      }
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
            BarChartRodData(toY: correct.toDouble(), color: Colors.green, width: 12),
            BarChartRodData(toY: wrong.toDouble(), color: Colors.red, width: 12),
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
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
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
                      child: Text(labels[index], style: const TextStyle(fontSize: 12)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Statistics"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGames,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Your Weekly Performance',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildBarChart(),
                _buildChartLegend(),

                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Recently Played',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                games.isNotEmpty
                    ? LayoutBuilder(
                  builder: (context, constraints) {
                    var mainAxisExtent = 600.0;
                    if (constraints.maxWidth <= 600) {
                      mainAxisExtent = constraints.maxWidth;
                    } else if (constraints.maxWidth <= 1000) {
                      mainAxisExtent = 650;
                    } else if (constraints.maxWidth <= 2000) {
                      mainAxisExtent = 1050;
                    } else {
                      mainAxisExtent = 1500;
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        mainAxisExtent: mainAxisExtent,
                      ),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return GameCard(
                          imagePath: game['imagePath'],
                          gameTitle: game['gameTitle'],
                          tags: List<String>.from(game['tags']),
                          gameId: game['gameId'],
                          loadGame: _loadGame,
                        );
                      },
                    );
                  },
                )
                    : const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No games have been played yet!'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
