import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_game/game.dart';
import 'package:flutterfire_game/player.dart';

class Brick extends PositionComponent with HasGameRef<MySimpleGame>, CollisionCallbacks {
  Brick({required Vector2 position}) : super(position: position) {
    size = Vector2(15, 15); // Small brick size
    anchor = Anchor.center;
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.brown;
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      gameRef.collectBrick();
      removeFromParent();
    }
  }
}
