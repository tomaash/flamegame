import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_game/game.dart';
import 'package:flutterfire_game/brick.dart';

enum WorldBlockType {
  dirt,
  edge,
  resetButton,
}

class WorldBlock extends PositionComponent with HasGameRef<MySimpleGame> {
  final edgePaint = Paint()..color = Color.fromARGB(255, 33, 33, 33);
  Paint paint;
  final WorldBlockType blockType;
  int hitCount = 0;
  static const maxHits = 5;
  
  WorldBlock(Vector2 position, Vector2 size, this.paint, this.blockType) : super(position: position, size: size);
  final hitBox = RectangleHitbox()..collisionType = CollisionType.passive;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(hitBox);
  }

  void onHit() {
    if (blockType != WorldBlockType.dirt) return;
    
    hitCount++;
    // Dim the color by reducing opacity
    final color = paint.color;
    paint = Paint()..color = color.withOpacity((1 - (hitCount / (maxHits+1)))*0.3);
    
    if (hitCount >= maxHits) {
      // Spawn a brick at the block's center position before removing
      if (blockType == WorldBlockType.dirt) {
        final centerPosition = position + size / 2;
        gameRef.world.add(Brick(position: centerPosition));
      }
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (blockType == WorldBlockType.resetButton) {
      final paintBlue = Paint()..color = Colors.blue;
      final paintRed = Paint()..color = Colors.red;
      canvas.drawRect(size.toRect(), paintBlue);
      canvas.drawRect(Rect.fromLTWH(size.x / 4, size.y / 4, size.x / 2, size.y / 2), paintRed);
      return;
    } else {
      canvas.drawRect(size.toRect(), blockType == WorldBlockType.edge ? edgePaint : paint);
    }
  }
}
