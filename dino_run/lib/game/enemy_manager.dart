import 'dart:math';
import 'package:flame/components.dart';
import '../models/enemy_data.dart';
import 'dino_run.dart';
import 'enemy.dart';
import 'speed-manager.dart';

class EnemyManager extends BaseComponent with HasGameRef<DinoRun> {
  final List<EnemyData> _data = [];

  Random _random = Random();

  Timer _timer = Timer(2, repeat: true);

  EnemyManager() {
    _timer.callback = spawnRandomEnemy;
  }

  void spawnRandomEnemy() {
    final randomIndex = _random.nextInt(_data.length);
    final enemyData = _data.elementAt(randomIndex);
    final enemy = Enemy(enemyData);
    enemy.anchor = Anchor.bottomLeft;
    enemy.position = Vector2(
      gameRef.size.x + 32,
      gameRef.size.y - 24,
    );

    if (enemyData.canFly) {
      final newHeight = _random.nextDouble() * 2 * enemyData.textureSize.y;
      enemy.position.y -= newHeight;
    }

    enemy.size = enemyData.textureSize;
    gameRef.add(enemy);
  }

  @override
  void onMount() {
    this.shouldRemove = false;

    if (_data.isEmpty) {
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
