import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_game/game.dart';
import 'package:flutterfire_game/brick.dart';
import 'package:flutterfire_game/bullet.dart';

class Shield extends PositionComponent with HasGameRef<MySimpleGame>, CollisionCallbacks {
  int hitCount = 3; // Number of hits the shield can take

  Shield({required Vector2 position, required double angle}) : super(position: position) {
    size = Vector2(70, 30); // Size of the shield
    anchor = Anchor.center;
    this.angle = angle; // Set the angle for rotation
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final opacity = (hitCount / 3).clamp(0.0, 1.0); // Calculate opacity based on hitCount
    final paint = Paint()..color = Colors.blue.withOpacity(opacity); // Apply opacity to color
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet) { // Assuming Bullet is the class that hits the shield
      hitCount--;
      if (hitCount <= 0) {
        // Produce a brick at the shield's position
        gameRef.world.add(Brick(position: position.clone()));
        removeFromParent(); // Remove the shield from the world
      }
    }
  }
}
