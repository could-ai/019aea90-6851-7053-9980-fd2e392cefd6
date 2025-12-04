import 'package:flutter/material.dart';

enum CarType { player, ai }

class Car {
  final String name;
  final CarType type;
  final Color color;
  
  double distanceTraveled = 0;
  double speed = 0;
  int nitroCount = 3;
  bool hasSpunOut = false;
  String lastAction = "Ready";

  // Constants
  static const double maxSpeed = 200.0;
  static const double acceleration = 20.0;
  static const double braking = 30.0;
  static const double nitroBoost = 50.0;
  static const double friction = 5.0; // Natural speed loss

  Car({
    required this.name,
    required this.type,
    required this.color,
  });

  void accelerate() {
    speed += acceleration;
    if (speed > maxSpeed) speed = maxSpeed;
    lastAction = "Accelerated";
    hasSpunOut = false;
  }

  void brake() {
    speed -= braking;
    if (speed < 0) speed = 0;
    lastAction = "Braked";
    hasSpunOut = false;
  }

  void useNitro() {
    if (nitroCount > 0) {
      speed += nitroBoost;
      // Nitro can exceed max speed slightly
      if (speed > maxSpeed + 50) speed = maxSpeed + 50;
      nitroCount--;
      lastAction = "NITRO BOOST!";
      hasSpunOut = false;
    } else {
      lastAction = "Nitro Empty!";
    }
  }

  void move() {
    if (hasSpunOut) {
      // Recovering from spin out
      speed = 0;
      hasSpunOut = false; // Recovered for next turn
      lastAction = "Recovering...";
      return;
    }

    distanceTraveled += speed;
    
    // Natural friction
    if (speed > 0) {
      speed -= friction;
      if (speed < 0) speed = 0;
    }
  }

  void spinOut() {
    speed = 0;
    hasSpunOut = true;
    lastAction = "SPUN OUT!";
  }
}
