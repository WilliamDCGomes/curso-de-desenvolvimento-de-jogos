import 'dart:ui';
import 'package:flame/geometry.dart';
import 'package:flame/components.dart';
import '../models/player_data.dart';
import 'dino_run.dart';
import 'enemy.dart';

enum DinoAnimationStates {
  Idle,
  Run,
  Kick,
  Hit,
  Sprint,
}

class Dino extends SpriteAnimationGroupComponent<DinoAnimationStates>
    with Hitbox, Collidable, HasGameRef<DinoRun> {
  static final _animationMap = {
    DinoAnimationStates.Idle: SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
    ),
    DinoAnimationStates.Run: SpriteAnimationData.sequenced(
      amount: 6,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4) * 24, 0),
    ),
    DinoAnimationStates.Kick: SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6) * 24, 0),
    ),
    DinoAnimationStates.Hit: SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6 + 4) * 24, 0),
    ),
    DinoAnimationStates.Sprint: SpriteAnimationData.sequenced(
      amount: 7,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6 + 4 + 3) * 24, 0),
    ),
  };
  double yMax = 0.0;
  double speedY = 0.0;
  Timer _hitTimer = Timer(1);

  static const double GRAVITY = 850;

  final PlayerData playerData;

  bool isHit = false;

  Dino(Image image, this.playerData)
      : super.fromFrameData(image, _animationMap);

  @override
  void onMount() {
    this._reset();
    final shape = HitboxRectangle(relation: Vector2(0.5, 0.7));
    addShape(shape);
    yMax = this.y;

    _hitTimer.callback = () {
      this.current = DinoAnimationStates.Run;
      this.isHit = false;
    };

    super.onMount();
  }

  @override
  void update(double dt) {
    this.speedY += GRAVITY * dt;

    this.y += this.speedY * dt;

    if (isOnGround) {
      this.y = this.yMax;
      this.speedY = 0.0;
      if ((this.current != DinoAnimationStates.Hit) &&
          (this.current != DinoAnimationStates.Run)) {
        this.current = DinoAnimationStates.Run;
      }
    }

    _hitTimer.update(dt);
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if ((other is Enemy) && (!isHit)) {
      this.hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  bool get isOnGround => (this.y >= this.yMax);

  void jump() {
    if (isOnGround) {
      this.speedY = -400;
      this.current = DinoAnimationStates.Idle;
    }
  }

  void hit() {
    this.isHit = true;
    this.current = DinoAnimationStates.Hit;
    _hitTimer.start();
    playerData.lives -= 1;
  }

  void _reset() {
    this.shouldRemove = false;
    this.anchor = Anchor.bottomLeft;
    this.position = Vector2(32, gameRef.size.y - 22);
    this.size = Vector2.all(24);
    this.current = DinoAnimationStates.Run;
    this.isHit = false;
    speedY = 0.0;
  }
}
