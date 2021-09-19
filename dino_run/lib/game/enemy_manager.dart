import 'dart:math';
import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/enemy_data.dart';
import 'dino_run.dart';
import 'enemy.dart';
import 'speed-manager.dart';


// This class is responsible for spawning random enemies at certain
// interval of time depending upon players current score.
class EnemyManager extends BaseComponent with HasGameRef<DinoRun> {
  // A list to hold data for all the enemies.
  final List<EnemyData> _data = [];

  // Random generator required for randomly selecting enemy type.
  Random _random = Random();

  // Timer to decide when to spawn next enemy.
  Timer _timer = Timer(2, repeat: true);

  EnemyManager() {
    _timer.callback = spawnRandomEnemy;
  }

  // This method is responsible for spawning a random enemy.
  void spawnRandomEnemy() {
    /// Generate a random index within [_data] and get an [EnemyData].
    final randomIndex = _random.nextInt(_data.length);
    final enemyData = _data.elementAt(randomIndex);
    final enemy = Enemy(enemyData);

    // Help in setting all enemies on ground.
    enemy.anchor = Anchor.bottomLeft;
    enemy.position = Vector2(
      gameRef.size.x + 32,
      gameRef.size.y - 24,
    );

    // If this enemy can fly, set its y position randomly.
    if (enemyData.canFly) {
      final newHeight = _random.nextDouble() * 2 * enemyData.textureSize.y;
      enemy.position.y -= newHeight;
    }

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    enemy.size = enemyData.textureSize;
    gameRef.add(enemy);
  }

  @override
  void onMount() {
    this.shouldRemove = false;

    // Don't fill list again and again on every mount.
    if (_data.isEmpty) {
      // As soon as this component is mounted, initilize all the data.
      _data.addAll([
        EnemyData(
          image: gameRef.images.fromCache('cacto.png'),
          nFrames: 1,
          stepTime: scenespeed().speedvelocity / 100,
          textureSize: Vector2(52, 52),
          speedX: scenespeed().speedvelocity * 5.5,
          canFly: false,
        ),
        EnemyData(
          image: gameRef.images.fromCache('meteor.png'),
          nFrames: 6,
          stepTime: scenespeed().speedvelocity / 100,
          textureSize: Vector2(96, 48),
          speedX: scenespeed().speedvelocity * 10,
          canFly: true,
        ),
        EnemyData(
          image: gameRef.images.fromCache('homemcaverna.png'),
          nFrames: 6,
          stepTime: scenespeed().speedvelocity / 100,
          textureSize: Vector2(24, 33),
          speedX: scenespeed().speedvelocity * 10,
          canFly: false,
        ),
      ]);
    }
    _timer.start();
    super.onMount();
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  void removeAllEnemies() {
    final enemies = gameRef.components.whereType<Enemy>();
    enemies.forEach((element) => element.remove());
  }
}
