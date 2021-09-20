import 'package:flame/geometry.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../models/enemy_data.dart';
import 'dino_run.dart';


class Enemy extends SpriteAnimationComponent
    with Hitbox, Collidable, HasGameRef<DinoRun> {
  final EnemyData enemyData;

  Enemy(this.enemyData) {
    this.animation = SpriteAnimation.fromFrameData(
      enemyData.image,
      SpriteAnimationData.sequenced(
        amount: enemyData.nFrames,
        stepTime: enemyData.stepTime,
        textureSize: enemyData.textureSize,
      ),
    );
  }

  @override
  void onMount() {
    final shape = HitboxRectangle(relation: Vector2.all(0.8));
    addShape(shape);
    this.size *= 0.6;
    super.onMount();
  }

  @override
  void update(double dt) {
    this.position.x -= enemyData.speedX * dt;

    if (this.position.x < -5) {
      remove();
      gameRef.playerData.currentScore += 1;
    }

    super.update(dt);
  }
}
