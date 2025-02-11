import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'bullet.dart';
import 'world_block.dart';
import 'player.dart';

class Enemy extends PositionComponent with CollisionCallbacks {
  static const double _size = 20.0;
  static const double _speed = 100.0;
  static const double _bounceFactor = 1; // How much velocity is preserved after bounce
  
  final Vector2 playerPosition;
  late Vector2 velocity;
  late Paint _paint;

  Enemy({required Vector2 position, required this.playerPosition}) : super(position: position) {
    size = Vector2.all(_size);
    anchor = Anchor.center;
    
    // Calculate initial velocity towards player
    velocity = (playerPosition - position).normalized() * _speed;
    
    // Set up the red paint for the triangle
    _paint = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;

    // Add hitbox
    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void render(Canvas canvas) {
    final path = Path();
    // Draw triangle pointing in movement direction
    final angle = velocity.angleToSigned(Vector2(1, 0));
    
    // Calculate triangle points and rotate them using matrix transformation
    final matrix4 = Matrix4.rotationZ(angle);
    
    final point1 = (matrix4.transformed3(Vector3(_size, 0, 0))).xy;
    final point2 = (matrix4.transformed3(Vector3(-_size/2, _size/2, 0))).xy;
    final point3 = (matrix4.transformed3(Vector3(-_size/2, -_size/2, 0))).xy;
    
    // Create triangle path
    path.moveTo(point1.x, point1.y);
    path.lineTo(point2.x, point2.y);
    path.lineTo(point3.x, point3.y);
    path.close();
    
    canvas.drawPath(path, _paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    if (other is Bullet) {
      removeFromParent();
      other.removeFromParent();
      return;
    }

    if (other is WorldBlock || other is Player) {
      if (intersectionPoints.length >= 2) {
        // Calculate normal from collision points
        final normal = getNormalFromPoints(intersectionPoints);
        // Reflect velocity around normal
        velocity = reflect(velocity, normal) * _bounceFactor;
      }
    }
  }

  Vector2 getNormalFromPoints(Set<Vector2> points) {
    if (points.length < 2) return Vector2(0, -1); // Default normal if not enough points
    
    final pointsList = points.toList();
    final collisionLine = pointsList[1] - pointsList[0];
    // Normal is perpendicular to collision line
    return Vector2(-collisionLine.y, collisionLine.x).normalized();
  }

  Vector2 reflect(Vector2 velocity, Vector2 normal) {
    // v' = v - 2(v·n)n
    return velocity - (normal * (2 * velocity.dot(normal)));
  }

  
}
