import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_game/world_block.dart';
import 'dart:math';
import 'player.dart';
import 'bullet.dart';
import 'shield.dart';
import 'brick.dart';
import 'enemy.dart';

const USE_ALTERNATIVE_CAMERA = false;

const double worldSize = 1500;

class MySimpleGame extends FlameGame with TapDetector, HasQuadTreeCollisionDetection {
  double _enemySpawnTimer = 0;
  static const double _enemySpawnInterval = 3.0; // Spawn enemy every 3 seconds
  late final JoystickComponent joystick;
  late final Player player;
  late final HudButtonComponent fireButton;
  late final HudButtonComponent placeShieldButton;
  late Sprite playerSprite;
  int brickCount = 0;
  late TextComponent brickCounter;

  // @override
  // final debugMode = true;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    initializeCollisionDetection(
      mapDimensions: Rect.fromLTWH(-worldSize, -worldSize, worldSize, worldSize),
      // mapDimensions: const Rect.fromLTWH(-100, -100, 100, 100),
      minimumDistance: 150,
      // maxLevels: 1,
      maxObjects: 100,
    );
    final playerSprite = await loadSprite('pac_man_0.png');
    this.playerSprite = playerSprite;

    // Define paints for the joystick knob and background
    final knobPaint = BasicPalette.blue.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.blue.withAlpha(100).paint();

    // Create the joystick component
    joystick = JoystickComponent(
        knob: CircleComponent(radius: 15, paint: knobPaint),
        background: CircleComponent(radius: 50, paint: backgroundPaint),
        margin: const EdgeInsets.only(left: 50, bottom: 60), // Position the joystick
        priority: 100);

    player = Player(joystick)
      ..sprite = playerSprite
      ..priority = 10;

    world.add(player);

    final shape = Rectangle.fromLTRB(player.minBounds.x, player.minBounds.y, player.maxBounds.x, player.maxBounds.y);

    camera = CameraComponent(world: world);
    camera.setBounds(shape);
    add(camera);
    camera.viewport.add(joystick);

    // Create the fire button component
    fireButton = HudButtonComponent(
      button: CircleComponent(radius: 30, paint: Paint()..color = Colors.red.withAlpha(150)),
      margin: const EdgeInsets.only(right: 50, bottom: 50),
      onPressed: () {
        // Handle fire button press
        // player.fire();

        final bullet = Bullet(
          position: player.position.clone(),
          direction: Vector2(cos(player.angle), sin(player.angle)),
          speed: 400,
          maxDistance: 500,
        );
        world.add(bullet);
      },
    );

    camera.viewport.add(fireButton);

    // Create the place shield button
    placeShieldButton = HudButtonComponent(
      button: CircleComponent(radius: 30, paint: Paint()..color = Colors.blue.withAlpha(150)),
      margin: const EdgeInsets.only(right: 150, bottom: 50),
      onPressed: () {
        if (brickCount > 0) {
          brickCount--;
          updateBrickCounter();
          // Place shield at player's position
          final angle = player.angle + (pi / 2);
          final shield = Shield(position: player.position.clone() + Vector2(cos(player.angle), sin(player.angle)) * 50, angle: angle);
          world.add(shield);
        }
      },
    );

    camera.viewport.add(placeShieldButton);

    if (!USE_ALTERNATIVE_CAMERA) {
      camera.follow(player);
    }

    // Add brick counter
    brickCounter = TextComponent(
      text: 'Bricks: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
    );
    camera.viewport.add(brickCounter);

    resetWorldBlocks();
  }

  void collectBrick() {
    brickCount++;
    brickCounter.text = 'Bricks: $brickCount';
  }

  void _spawnEnemy() {
    final random = Random();
    final playerSpace = 200.0; // Same as in resetWorldBlocks
    
    // Generate random position within the starting area
    final spawnPosition = Vector2(
      (random.nextDouble() * 2 - 1) * playerSpace * 0.8, // 80% of playerSpace
      (random.nextDouble() * 2 - 1) * playerSpace * 0.8,
    );
    
    final enemy = Enemy(
      position: spawnPosition,
      playerPosition: player.position,
    );
    world.add(enemy);
  }

  void updateBrickCounter() {
    brickCounter.text = 'Bricks: $brickCount';
  }

  void resetWorldBlocks() async {
    world.removeAll(world.children.whereType<WorldBlock>());
    world.removeAll(world.children.whereType<Bullet>());
    player.position = Vector2(0, 0);

    final random = Random();

    var resetDone = false;
    var makeReset = false;

    final playerSpace = 200;
    final double blockSize = 120;
    final xSteps = (player.maxBounds.x - player.minBounds.x) ~/ blockSize;
    final ySteps = (player.maxBounds.y - player.minBounds.y) ~/ blockSize;

    for (var i = 0; i < xSteps; i++) {
      for (var j = 0; j < ySteps; j++) {
        final isEdge = i == 0 || j == 0 || i == xSteps - 1 || j == ySteps - 1;
        // if (random.nextDouble() > 0.7 || isEdge) {
        final dx = blockSize * i;
        final dy = blockSize * j;
        final posX = player.minBounds.x + dx;
        final posY = player.minBounds.y + dy;

        if (posX.abs() < playerSpace && posY.abs() < playerSpace) {
          if (!resetDone) {
            makeReset = true;
          }
          continue;
        }

        final position = Vector2(posX, posY);
        final size = Vector2(blockSize, blockSize);
        final color = isEdge
            ? Color.fromARGB(255, 33, 33, 33)
            : Color.fromARGB(
                100,
                random.nextInt(256),
                random.nextInt(256),
                random.nextInt(256),
              );
        final block = WorldBlock(
            position,
            size,
            Paint()..color = color,
            makeReset
                ? WorldBlockType.resetButton
                : isEdge
                    ? WorldBlockType.edge
                    : WorldBlockType.dirt);
        if (makeReset) {
          makeReset = false;
          resetDone = true;
        }
        world.add(block);
        // }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Update enemy spawn timer
    final enemyCount = world.children.whereType<Enemy>().length;
    if (enemyCount < 2) {
      _enemySpawnTimer += dt;
      if (_enemySpawnTimer >= _enemySpawnInterval) {
        _enemySpawnTimer = 0;
        _spawnEnemy();
      }
    }

    if (USE_ALTERNATIVE_CAMERA) {
      final visibleRect = camera.visibleWorldRect;
      const edgeThreshold = 130;

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
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }
}
