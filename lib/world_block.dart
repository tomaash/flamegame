import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum WorldBlockType {
  dirt,
  edge,
  resetButton,
}

class WorldBlock extends PositionComponent {
  final edgePaint = Paint()..color = Color.fromARGB(255, 33, 33, 33);
  final Paint paint;
  final WorldBlockType blockType;
  WorldBlock(Vector2 position, Vector2 size, this.paint, this.blockType) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox()..collisionType = CollisionType.passive); // Add rectangular hitbox
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
