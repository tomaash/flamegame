import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_game/game.dart';
import 'package:flutterfire_game/world_block.dart';

class Player extends SpriteComponent with HasGameRef<MySimpleGame>, CollisionCallbacks {
  bool collided = false;
  // JoystickDirection collidedDirection = JoystickDirection.idle;
  Vector2 collidedDelta = Vector2.zero();

  final Vector2 minBounds = Vector2(-worldSize, -worldSize);
  final Vector2 maxBounds = Vector2(worldSize, worldSize);

  final JoystickComponent joystick;
  double speed = 200; // Pixels per second
  Map<PositionComponent, Vector2> collidedComponents = {};

  Player(this.joystick);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(50, 50); // Set size of the player.
    position = Vector2(0, 0); // Initial position.
    anchor = Anchor.center; // Anchor the player in the center.
    nativeAngle = -pi / 2; // Set the initial angle to point up.
    add(RectangleHitbox()..collisionType = CollisionType.active); // Adds a rectangular hitbox
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

      var xCollided = false;
      var yCollided = false;

      collidedComponents.forEach((key, value) {
        if (value.x * joyDelta.x > 0) {
          xCollided = true;
        }

        if (value.y * joyDelta.y > 0) {
          yCollided = true;
        }
      });

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

  // void fire() {
  //   final bullet = Bullet(
  //     position: position.clone(),
  //     direction: Vector2(cos(angle), sin(angle)),
  //     speed: 400,
  //     maxDistance: 200,
  //   );
  // }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    Vector2 cn1 = intersectionPoints.first - position;
    Vector2 cn2 = intersectionPoints.last - position;

    final collisionNormal = (cn1 + cn2) / 2;

    collidedComponents[other] = collisionNormal;

    if (other is WorldBlock) {
      if (other.blockType == WorldBlockType.resetButton) {
        gameRef.resetWorldBlocks();
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    collidedComponents.remove(other);
    super.onCollisionEnd(other);
  }
}
