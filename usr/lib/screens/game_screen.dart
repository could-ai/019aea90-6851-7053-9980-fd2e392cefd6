import 'package:flutter/material.dart';
import 'package:couldai_user_app/logic/game_logic.dart';
import 'package:couldai_user_app/models/car.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameLogic _gameLogic;

  @override
  void initState() {
    super.initState();
    _gameLogic = GameLogic();
  }

  void _handleAction(String action) {
    setState(() {
      _gameLogic.executeTurn(action);
    });

    if (_gameLogic.isGameOver) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          _gameLogic.winner == _gameLogic.playerCar.name ? "VICTORY!" : "DEFEAT",
          style: TextStyle(
            color: _gameLogic.winner == _gameLogic.playerCar.name ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "${_gameLogic.winner} won the race!",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text("Exit"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _gameLogic.reset();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Rematch", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Race Track'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(child: Text("Turn: ${_gameLogic.turnNumber}")),
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Track Visualization
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Stack(
                children: [
                  // Track Lines
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TrackPainter(
                        trackLength: _gameLogic.trackLength,
                        curves: _gameLogic.curves,
                      ),
                    ),
                  ),
                  
                  // Player Car
                  _buildCarWidget(_gameLogic.playerCar, true),
                  
                  // AI Car
                  _buildCarWidget(_gameLogic.aiCar, false),
                  
                  // Finish Line Label
                  const Positioned(
                    right: 10,
                    top: 10,
                    child: Text("FINISH", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          // 2. Info Dashboard
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard(_gameLogic.playerCar)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard(_gameLogic.aiCar)),
                ],
              ),
            ),
          ),

          // 3. Event Log
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black26,
            width: double.infinity,
            child: Text(
              _gameLogic.eventLog,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold),
            ),
          ),

          // 4. Controls
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton("BRAKE", Colors.orange, Icons.remove_circle_outline),
                  _buildActionButton("ACCELERATE", Colors.green, Icons.add_circle_outline),
                  _buildActionButton("NITRO (${_gameLogic.playerCar.nitroCount})", Colors.blue, Icons.flash_on),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarWidget(Car car, bool isPlayer) {
    // Calculate relative position (0.0 to 1.0)
    double progress = car.distanceTraveled / _gameLogic.trackLength;
    if (progress > 1.0) progress = 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        double trackWidth = constraints.maxWidth - 60; // Padding
        double leftPos = trackWidth * progress + 10;
        
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          left: leftPos,
          top: isPlayer ? constraints.maxHeight * 0.6 : constraints.maxHeight * 0.2,
          child: Column(
            children: [
              Icon(
                Icons.directions_car_filled,
                color: car.color,
                size: 40,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  car.name,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              if (car.hasSpunOut)
                const Text("⚠ SPIN!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(Car car) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: car.color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: car.color, size: 16),
              const SizedBox(width: 8),
              Text(car.name, style: TextStyle(color: car.color, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.grey),
          _buildStatRow("Speed", "${car.speed.toInt()} km/h"),
          _buildStatRow("Dist", "${car.distanceTraveled.toInt()} m"),
          _buildStatRow("Last", car.lastAction),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon) {
    bool isDisabled = label.startsWith("NITRO") && _gameLogic.playerCar.nitroCount <= 0;
    
    return ElevatedButton(
      onPressed: isDisabled ? null : () => _handleAction(label.split(' ')[0]),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        disabledBackgroundColor: Colors.grey[800],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class TrackPainter extends CustomPainter {
  final double trackLength;
  final List<double> curves;

  TrackPainter({required this.trackLength, required this.curves});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 2;

    // Draw track lines
    double y1 = size.height * 0.2 + 20; // AI lane center
    double y2 = size.height * 0.6 + 20; // Player lane center

    // Draw finish line
    final finishPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    // Draw start line
    canvas.drawLine(const Offset(10, 0), Offset(10, size.height), finishPaint);
    
    // Draw finish line (approximate at end of container)
    canvas.drawLine(Offset(size.width - 20, 0), Offset(size.width - 20, size.height), finishPaint);
    
    // Draw Curve Markers
    final curvePaint = Paint()
      ..color = Colors.yellow.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (double curveDist in curves) {
      double relativePos = curveDist / trackLength;
      if (relativePos <= 1.0) {
        double x = (size.width - 60) * relativePos + 10;
        // Draw a "danger zone" rectangle
        canvas.drawRect(Rect.fromLTWH(x - 10, 0, 20, size.height), curvePaint);
        
        // Draw warning text
        // TextPainter(
        //   text: const TextSpan(text: "!", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
        //   textDirection: TextDirection.ltr
        // )..layout()..paint(canvas, Offset(x - 5, size.height / 2 - 10));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
