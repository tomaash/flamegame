import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_game/player.dart';
import 'package:flutterfire_game/world_block.dart';
import 'package:flutterfire_game/game.dart';

class Bullet extends PositionComponent with HasGameRef<MySimpleGame>, CollisionCallbacks {
  final Vector2 direction;
  final double speed;
  final double maxDistance;
  double traveled = 0;

  Bullet({
    required Vector2 position,
    required this.direction,
    required this.speed,
    required this.maxDistance,
  }) {
    this.position = position;
    size = Vector2(10, 10);
    anchor = Anchor.center;
    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final move = direction * speed * dt;
    position.add(move);
    traveled += move.length;
    if (traveled >= maxDistance) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.lightGreenAccent;
    canvas.drawCircle(Offset.zero, size.x / 2, paint);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet || other is Player) {
      return;
    }
    removeFromParent();
    super.onCollision(intersectionPoints, other);

    if (other is WorldBlock) {
      if (other.blockType == WorldBlockType.edge) {
        // return;
      } else if (other.blockType == WorldBlockType.resetButton) {
        // gameRef.resetWorldBlocks();
      } else {
        other.onHit();
      }
    }
  }
}
