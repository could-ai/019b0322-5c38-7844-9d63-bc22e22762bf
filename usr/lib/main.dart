import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('pt_PT', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsões Desportivas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        cardTheme: const CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.white,
        ),
      ),
      home: const SportsPredictionsScreen(),
    );
  }
}

// --- Models ---

enum SportType {
  football,
  basketball,
  hockey,
}

class GamePrediction {
  final String marketName; // e.g., "Vitória Casa", "Mais de 2.5 Golos"
  final double probability; // 0.0 to 1.0

  GamePrediction({required this.marketName, required this.probability});
}

class Game {
  final String id;
  final SportType sport;
  final String homeTeam;
  final String awayTeam;
  final DateTime startTime;
  final GamePrediction bestPrediction;

  Game({
    required this.id,
    required this.sport,
    required this.homeTeam,
    required this.awayTeam,
    required this.startTime,
    required this.bestPrediction,
  });
}

// --- Mock Data Service ---

class MockDataService {
  static List<Game> getGames() {
    final now = DateTime.now();
    final List<Game> games = [];
    
    // Helper to add hours
    DateTime time(int days, int hours) => now.add(Duration(days: days, hours: hours));

    // Sample Data
    games.add(Game(
      id: '1',
      sport: SportType.football,
      homeTeam: 'Benfica',
      awayTeam: 'Porto',
      startTime: time(0, 2), // Today + 2 hours
      bestPrediction: GamePrediction(marketName: 'Mais de 1.5 Golos', probability: 0.96),
    ));

    games.add(Game(
      id: '2',
      sport: SportType.basketball,
      homeTeam: 'Lakers',
      awayTeam: 'Warriors',
      startTime: time(0, 5),
      bestPrediction: GamePrediction(marketName: 'Lakers Vence', probability: 0.92), // Below 95%
    ));

    games.add(Game(
      id: '3',
      sport: SportType.hockey,
      homeTeam: 'Bruins',
      awayTeam: 'Maple Leafs',
      startTime: time(1, 1), // Tomorrow
      bestPrediction: GamePrediction(marketName: 'Menos de 7.5 Golos', probability: 0.97),
    ));

    games.add(Game(
      id: '4',
      sport: SportType.football,
      homeTeam: 'Real Madrid',
      awayTeam: 'Barcelona',
      startTime: time(2, 18),
      bestPrediction: GamePrediction(marketName: 'Ambas Marcam', probability: 0.98),
    ));

    games.add(Game(
      id: '5',
      sport: SportType.basketball,
      homeTeam: 'Celtics',
      awayTeam: 'Heat',
      startTime: time(0, 8),
      bestPrediction: GamePrediction(marketName: 'Mais de 200 Pontos', probability: 0.99),
    ));

    games.add(Game(
      id: '6',
      sport: SportType.hockey,
      homeTeam: 'Oilers',
      awayTeam: 'Flames',
      startTime: time(3, 20),
      bestPrediction: GamePrediction(marketName: 'Oilers Vence', probability: 0.95),
    ));

    games.add(Game(
      id: '7',
      sport: SportType.football,
      homeTeam: 'Sporting CP',
      awayTeam: 'Braga',
      startTime: time(1, 19),
      bestPrediction: GamePrediction(marketName: 'Sporting Vence', probability: 0.96),
    ));
    
    games.add(Game(
      id: '8',
      sport: SportType.football,
      homeTeam: 'Man City',
      awayTeam: 'Liverpool',
      startTime: time(4, 16),
      bestPrediction: GamePrediction(marketName: 'Mais de 2.5 Golos', probability: 0.88), // Below 95%
    ));

     games.add(Game(
      id: '9',
      sport: SportType.basketball,
      homeTeam: 'Bulls',
      awayTeam: 'Knicks',
      startTime: time(2, 22),
      bestPrediction: GamePrediction(marketName: 'Knicks Vence', probability: 0.97),
    ));

    return games;
  }
}

// --- UI Screens ---

class SportsPredictionsScreen extends StatefulWidget {
  const SportsPredictionsScreen({super.key});

  @override
  State<SportsPredictionsScreen> createState() => _SportsPredictionsScreenState();
}

class _SportsPredictionsScreenState extends State<SportsPredictionsScreen> {
  List<Game> _allGames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final games = MockDataService.getGames();
    
    // Sort by time (nearest first)
    games.sort((a, b) => a.startTime.compareTo(b.startTime));

    setState(() {
      _allGames = games;
      _isLoading = false;
    });
  }

  // Filter logic: Only games with probability >= 95%
  List<Game> get _filteredGames {
    return _allGames.where((game) => game.bestPrediction.probability >= 0.95).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gamesToShow = _filteredGames;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jogos Alta Probabilidade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Taxa de acerto > 95%', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadGames();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : gamesToShow.isEmpty
              ? const Center(child: Text('Nenhum jogo com >95% encontrado.'))
              : ListView.builder(
                  itemCount: gamesToShow.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    return GameCard(game: gamesToShow[index]);
                  },
                ),
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  String _formatDate(DateTime date) {
    // Format: "Hoje, 19:30" or "Seg, 14:00"
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isTomorrow = date.year == now.year && date.month == now.month && date.day == now.day + 1;

    final timeStr = DateFormat('HH:mm').format(date);
    
    if (isToday) return 'Hoje, $timeStr';
    if (isTomorrow) return 'Amanhã, $timeStr';
    
    // Portuguese locale for day name
    return '${DateFormat('EEE, dd MMM', 'pt_PT').format(date)}, $timeStr';
  }

  IconData _getSportIcon(SportType type) {
    switch (type) {
      case SportType.football:
        return Icons.sports_soccer;
      case SportType.basketball:
        return Icons.sports_basketball;
      case SportType.hockey:
        return Icons.sports_hockey;
    }
  }

  Color _getSportColor(SportType type) {
    switch (type) {
      case SportType.football:
        return Colors.green.shade700;
      case SportType.basketball:
        return Colors.orange.shade800;
      case SportType.hockey:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final probabilityPercent = (game.bestPrediction.probability * 100).toStringAsFixed(0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header: Sport and Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: _getSportColor(game.sport).withOpacity(0.1),
            child: Row(
              children: [
                Icon(_getSportIcon(game.sport), size: 18, color: _getSportColor(game.sport)),
                const SizedBox(width: 8),
                Text(
                  _getSportName(game.sport),
                  style: TextStyle(
                    color: _getSportColor(game.sport),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDate(game.startTime),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Match Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.homeTeam,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.awayTeam,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                // Probability Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$probabilityPercent%',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Text(
                        'Confiança',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Prediction Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                const Icon(Icons.analytics_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Previsão: ${game.bestPrediction.marketName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSportName(SportType type) {
    switch (type) {
      case SportType.football: return 'Futebol';
      case SportType.basketball: return 'Basquetebol';
      case SportType.hockey: return 'Hóquei no Gelo';
    }
  }
}
