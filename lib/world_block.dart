import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WorldBlock extends PositionComponent {
  final Paint paint;
  WorldBlock(Vector2 position, Vector2 size, this.paint) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox()); // Add rectangular hitbox
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), paint);
  }
}
