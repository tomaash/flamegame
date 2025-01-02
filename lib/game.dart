import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'player.dart';

class MySimpleGame extends FlameGame with TapDetector {
  late final JoystickComponent joystick;
  late final Player player;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final playerSprite = await loadSprite('pac_man_0.png');

    // Define paints for the joystick knob and background
    final knobPaint = BasicPalette.blue.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.blue.withAlpha(100).paint();

    // Create the joystick component
    joystick = JoystickComponent(
        knob: CircleComponent(radius: 15, paint: knobPaint),
        background: CircleComponent(radius: 50, paint: backgroundPaint),
        margin: const EdgeInsets.only(left: 20, bottom: 20), // Position the joystick
        priority: 100);

    // final parallaxComponent =
    //     await loadParallaxComponent([ParallaxImageData('bg.jpg')], repeat: ImageRepeat.repeat, priority: -1);

    final random = Random();
    for (var i = 0; i < 100; i++) {
      final position = Vector2(random.nextDouble() * 1000 - 500, random.nextDouble() * 1000 - 500);
      final size = Vector2(random.nextDouble() * 100 + 20, random.nextDouble() * 100 + 20);
      final color = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
      final rectangle = RectangleComponent(position: position, size: size, paint: Paint()..color = color);
      world.add(rectangle);
    }

    add(joystick);

    player = Player(joystick)..sprite = playerSprite;

    world.add(player);

    final shape = Rectangle.fromLTRB(player.minBounds.x, player.minBounds.y, player.maxBounds.x, player.maxBounds.y);

    camera = CameraComponent(world: world);
    camera.setBounds(shape);
    add(camera);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final visibleRect = camera.visibleWorldRect;
    const edgeThreshold = 100;

    // Check if player is near any screen edge
    bool isLeft = player.position.x < visibleRect.left + edgeThreshold;
    bool isRight = player.position.x > visibleRect.right - edgeThreshold;
    bool isTop = player.position.y < visibleRect.top + edgeThreshold;
    bool isBottom = player.position.y > visibleRect.bottom - edgeThreshold;

    final dist = player.speed * dt;
    final dx = joystick.relativeDelta.x;
    final dy = joystick.relativeDelta.y;

    final moveX = Vector2(dx * dist, 0);
    final moveY = Vector2(0, dy * dist);

    if (isLeft && dx < 0 || isRight && dx > 0) {
      camera.moveBy(moveX);
    }

    if (isTop && dy < 0 || isBottom && dy > 0) {
      camera.moveBy(moveY);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }
}
