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
import 'audio_manager.dart';
import 'dino.dart';
import 'enemy_manager.dart';
import 'speed-manager.dart';

// This is the main flame game class.
class DinoRun extends BaseGame with TapDetector, HasCollidables {
  // List of all the image assets.
  static const _imageAssets = [
    'DinoSprites - tard.png',
    'cacto.png',
    'meteor.png',
    'homemcaverna.png',
  ];

  // List of all the audio assets.
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

  // This method get called while flame is preparing this game.
  @override
  Future<void> onLoad() async {
    /// Read [PlayerData] and [Settings] from hive.
    playerData = await _readPlayerData();
    settings = await _readSettings();

    /// Initilize [AudioManager].
    await AudioManager.instance.init(_audioAssets, settings);

    // Start playing background music. Internally takes care
    // of checking user settings.
    AudioManager.instance.startBgm('8Bit Platformer Loop.wav');

    // Cache all the images.
    await images.loadAll(_imageAssets);

    // Set a fixed viewport to avoid manually scaling
    // and handling different screen sizes.
    this.viewport = FixedResolutionViewport(Vector2(360, 180));

    /// Create a [ParallaxComponent] and add it to game.
    parallaxBackground = await loadParallaxComponent(
      [
        ParallaxImageData('background.png'),
      ],
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(scenespeed().speedvelocity / 2, 0),
    );
    add(parallaxBackground);

    // Create the main hero of this game.
    _dino = Dino(images.fromCache('DinoSprites - tard.png'), playerData);
    // Create an enemy manager.
    _enemyManager = EnemyManager();

    return super.onLoad();
  }

  /// This method add the already created [Dino]
  /// and [EnemyManager] to this game.
  void startGamePlay() {
    add(_dino);
    add(_enemyManager);
  }

  // This method remove all the actors from the game.
  void _disconnectActors() {
    _dino.remove();
    _enemyManager.removeAllEnemies();
    _enemyManager.remove();
  }

  // This method reset the whole game world to initial state.
  void reset() {
    // First disconnect all actions from game world.
    _disconnectActors();

    // Reset player data to inital values.
    playerData.currentScore = 0;
    playerData.lives = 5;
  }

  // This method gets called for each tick/frame of the game.
  @override
  void update(double dt) {
    // If number of lives is 0 or less, game is over.
    if (playerData.lives <= 0) {
      this.overlays.add(GameOverMenu.id);
      this.overlays.remove(Hud.id);
      this.pauseEngine();
      AudioManager.instance.pauseBgm();
    }
    super.update(dt);
  }

  // This will get called for each tap on the screen.
  @override
  void onTapDown(TapDownInfo info) {
    scenespeed().IncreeseSpeend();
    // Make dino jump only when game is playing.
    // When game is in playing state, only Hud will be the active overlay.
    if (this.overlays.isActive(Hud.id)) {
      _dino.jump();
    }
    super.onTapDown(info);
  }

  /// This method reads [PlayerData] from the hive box.
  Future<PlayerData> _readPlayerData() async {
    final playerDataBox =
        await Hive.openBox<PlayerData>('DinoRun.PlayerDataBox');
    final playerData = playerDataBox.get('DinoRun.PlayerData');

    // If data is null, this is probably a fresh launch of the game.
    if (playerData == null) {
      // In such cases store default values in hive.
      await playerDataBox.put('DinoRun.PlayerData', PlayerData());
    }

    // Now it is safe to return the stored value.
    return playerDataBox.get('DinoRun.PlayerData')!;
  }

  /// This method reads [Settings] from the hive box.
  Future<Settings> _readSettings() async {
    final settingsBox = await Hive.openBox<Settings>('DinoRun.SettingsBox');
    final settings = settingsBox.get('DinoRun.Settings');

    // If data is null, this is probably a fresh launch of the game.
    if (settings == null) {
      // In such cases store default values in hive.
      await settingsBox.put(
        'DinoRun.Settings',
        Settings(bgm: true, sfx: true),
      );
    }

    // Now it is safe to return the stored value.
    return settingsBox.get('DinoRun.Settings')!;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // On resume, if active overlay is not PauseMenu,
        // resume the engine (lets the parallax effect play).
        if (!(this.overlays.isActive(PauseMenu.id)) &&
            !(this.overlays.isActive(GameOverMenu.id))) {
          this.resumeEngine();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        // If game is active, then remove Hud and add PauseMenu
        // before pausing the game.
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
