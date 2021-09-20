import 'package:flame/game.dart';
import 'package:hive/hive.dart';
import 'package:flame/gestures.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../models/player_data.dart';
import '../models/settings.dart';
import '../widgets/game_over_menu.dart';
import '../widgets/hud.dart';
import '../widgets/pause_menu.dart';
import 'dino.dart';
import 'enemy_manager.dart';
import 'speed-manager.dart';

class DinoRun extends BaseGame with TapDetector, HasCollidables {
  static const _imageAssets = [
    'DinoSprites - tard.png',
    'cacto.png',
    'meteor.png',
    'homemcaverna.png',
  ];

  static const _audioAssets = [
    '8Bit Platformer Loop.wav',
    'hurt7.wav',
    'jump14.wav',
  ];

  late Dino _dino;
  late Settings settings;
  late PlayerData playerData;
  late EnemyManager _enemyManager;
  late ParallaxComponent parallaxBackground;

  @override
  Future<void> onLoad() async {
    playerData = await _readPlayerData();
    settings = await _readSettings();

    await images.loadAll(_imageAssets);

    this.viewport = FixedResolutionViewport(Vector2(360, 180));

    parallaxBackground = await loadParallaxComponent(
      [
        ParallaxImageData('background.png'),
      ],
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(scenespeed().speedvelocity / 2, 0),
    );
    add(parallaxBackground);

    _dino = Dino(images.fromCache('DinoSprites - tard.png'), playerData);

    _enemyManager = EnemyManager();

    return super.onLoad();
  }

  void startGamePlay() {
    add(_dino);
    add(_enemyManager);
  }

  void _disconnectActors() {
    _dino.remove();
    _enemyManager.removeAllEnemies();
    _enemyManager.remove();
  }

  void reset() {
    _disconnectActors();

    playerData.currentScore = 0;
    playerData.lives = 5;
  }

  @override
  void update(double dt) {
    if (playerData.lives <= 0) {
      this.overlays.add(GameOverMenu.id);
      this.overlays.remove(Hud.id);
      this.pauseEngine();
    }
    super.update(dt);
  }

  @override
  void onTapDown(TapDownInfo info) {
    scenespeed().IncreeseSpeend();
    if (this.overlays.isActive(Hud.id)) {
      _dino.jump();
    }
    super.onTapDown(info);
  }

  Future<PlayerData> _readPlayerData() async {
    final playerDataBox =
        await Hive.openBox<PlayerData>('DinoRun.PlayerDataBox');
    final playerData = playerDataBox.get('DinoRun.PlayerData');

    if (playerData == null) {
      await playerDataBox.put('DinoRun.PlayerData', PlayerData());
    }

    return playerDataBox.get('DinoRun.PlayerData')!;
  }

  Future<Settings> _readSettings() async {
    final settingsBox = await Hive.openBox<Settings>('DinoRun.SettingsBox');
    final settings = settingsBox.get('DinoRun.Settings');

    if (settings == null) {
      await settingsBox.put(
        'DinoRun.Settings',
        Settings(bgm: true, sfx: true),
      );
    }

    return settingsBox.get('DinoRun.Settings')!;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!(this.overlays.isActive(PauseMenu.id)) &&
            !(this.overlays.isActive(GameOverMenu.id))) {
          this.resumeEngine();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        if (this.overlays.isActive(Hud.id)) {
          this.overlays.remove(Hud.id);
          this.overlays.add(PauseMenu.id);
        }
        this.pauseEngine();
        break;
    }
    super.lifecycleStateChange(state);
  }
}
