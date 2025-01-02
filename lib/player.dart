import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_game/game.dart';

class Player extends SpriteComponent with HasGameRef<MySimpleGame>, CollisionCallbacks {
  bool collided = false;
  JoystickDirection collidedDirection = JoystickDirection.idle;
  Vector2 collidedDelta = Vector2.zero();

  final Vector2 minBounds = Vector2(-1500, -1500);
  final Vector2 maxBounds = Vector2(1500, 1500);

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
    add(CircleHitbox()..collisionType = CollisionType.active); // Adds a rectangular hitbox
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (joystick.direction != JoystickDirection.idle) {
      final joyDelta = joystick.relativeDelta.clone();

      // Directions are same, then collided
      final xCollided = collidedDelta.x * joyDelta.x > 0;
      final yCollided = collidedDelta.y * joyDelta.y > 0;

      if (xCollided) {
        joyDelta.x = 0;
      }

      if (yCollided) {
        joyDelta.y = 0;
      }

      position.add(joyDelta * speed * dt);
      angle = joystick.delta.screenAngle() + nativeAngle; // Rotate based on direction
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Record the direction of collision
    if (!collided) {
      collidedDirection = joystick.direction;
      collidedDelta = joystick.relativeDelta;
    }

    collided = true;

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    // if (other is Obstacle) {
    collided = false;
    collidedDirection = JoystickDirection.idle;
    collidedDelta = Vector2.zero();
    // }
    super.onCollisionEnd(other);
  }
}
