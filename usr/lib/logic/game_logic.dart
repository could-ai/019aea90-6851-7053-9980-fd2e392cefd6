import 'dart:math';
import 'package:couldai_user_app/models/car.dart';

class GameLogic {
  final double trackLength;
  final List<double> curves; // Distances where curves are located
  final double curveSpeedLimit = 120.0; // Speed limit for curves

  late Car playerCar;
  late Car aiCar;
  int turnNumber = 1;
  bool isGameOver = false;
  String? winner;
  String eventLog = "Race Start!";

  GameLogic({this.trackLength = 2000.0}) : curves = [] {
    // Generate some random curves
    final random = Random();
    int numberOfCurves = 4;
    double segment = trackLength / (numberOfCurves + 1);
    for (int i = 1; i <= numberOfCurves; i++) {
      curves.add(segment * i + random.nextInt(100) - 50);
    }
    
    reset();
  }

  void reset() {
    playerCar = Car(name: "Player 1", type: CarType.player, color: const Color(0xFFE53935)); // Red
    aiCar = Car(name: "Rival Bot", type: CarType.ai, color: const Color(0xFF1E88E5)); // Blue
    turnNumber = 1;
    isGameOver = false;
    winner = null;
    eventLog = "Race Start! Watch out for curves at ${curves.map((e) => e.toInt()).join(', ')}m.";
  }

  void executeTurn(String playerAction) {
    if (isGameOver) return;

    // 1. Player Action
    switch (playerAction) {
      case 'ACCELERATE':
        playerCar.accelerate();
        break;
      case 'BRAKE':
        playerCar.brake();
        break;
      case 'NITRO':
        playerCar.useNitro();
        break;
    }

    // 2. AI Action (Simple Logic)
    _executeAIAction();

    // 3. Check for Curves BEFORE moving fully
    // We check if the movement WOULD pass a curve
    _checkCurveMechanics(playerCar);
    _checkCurveMechanics(aiCar);

    // 4. Move Cars
    playerCar.move();
    aiCar.move();

    // 5. Check Win Condition
    if (playerCar.distanceTraveled >= trackLength || aiCar.distanceTraveled >= trackLength) {
      isGameOver = true;
      if (playerCar.distanceTraveled > aiCar.distanceTraveled) {
        winner = playerCar.name;
        eventLog = "YOU WON!";
      } else {
        winner = aiCar.name;
        eventLog = "Rival Bot Wins!";
      }
    } else {
      turnNumber++;
    }
  }

  void _executeAIAction() {
    // AI Logic:
    // If approaching a curve and too fast -> Brake
    // If straight -> Accelerate
    // If behind and straight -> Nitro

    double distToNextCurve = double.infinity;
    for (double curve in curves) {
      if (curve > aiCar.distanceTraveled) {
        distToNextCurve = curve - aiCar.distanceTraveled;
        break;
      }
    }

    if (distToNextCurve < 200 && aiCar.speed > curveSpeedLimit) {
      aiCar.brake();
    } else if (distToNextCurve > 500 && aiCar.nitroCount > 0 && aiCar.speed < 150) {
      aiCar.useNitro();
    } else {
      aiCar.accelerate();
    }
  }

  void _checkCurveMechanics(Car car) {
    // Check if the car passes a curve in this turn
    // Estimated movement = current speed (simplified)
    double estimatedNextPos = car.distanceTraveled + car.speed;
    
    for (double curve in curves) {
      if (car.distanceTraveled < curve && estimatedNextPos >= curve) {
        // Crossing a curve
        if (car.speed > curveSpeedLimit) {
          car.spinOut();
          // Log event only for player to avoid clutter, or generic log
          if (car.type == CarType.player) {
            eventLog = "You spun out on a curve! Too fast!";
          }
        }
      }
    }
  }
}
