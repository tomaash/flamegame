import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_game/game.dart';

class Player extends SpriteComponent with HasGameRef<MySimpleGame> {
  // Vector2? targetPosition;

  final Vector2 minBounds = Vector2(-500, -500);
  final Vector2 maxBounds = Vector2(500, 500);

  final JoystickComponent joystick;
  double speed = 200; // Pixels per second

  Player(this.joystick);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(50, 50); // Set size of the player.
    position = Vector2(0, 0); // Initial position.
    anchor = Anchor.center; // Anchor the player in the center.
    nativeAngle = -pi / 2; // Set the initial angle to point up.
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // final paint = Paint()..color = Colors.red;
    // canvas.drawRect(size.toRect(), paint); // Draw a blue square.
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the player based on joystick input
    if (joystick.direction != JoystickDirection.idle) {
      position.add(joystick.relativeDelta * speed * dt);
      position.clamp(minBounds, maxBounds); // Clamp the player position to the bounds.
      angle = joystick.delta.screenAngle() + nativeAngle; // Rotate based on direction
    }
  }

  // @override
  // void update(double dt) {
  //   super.update(dt);
  //   print("update: $dt");
  //   if (targetPosition != null) {
  //     final direction = (targetPosition! - position).normalized();
  //     position += direction * 100 * dt; // Move 100 units per second.
  //     if ((targetPosition! - position).length < 1) {
  //       position = targetPosition!;
  //       targetPosition = null;
  //     }
  //   }
  // }
}
