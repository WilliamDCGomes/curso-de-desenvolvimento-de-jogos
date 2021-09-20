import 'package:hive/hive.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'widgets/hud.dart';
import 'game/dino_run.dart';
import 'models/settings.dart';
import 'widgets/main_menu.dart';
import 'models/player_data.dart';
import 'widgets/pause_menu.dart';
import 'widgets/game_over_menu.dart';

DinoRun _dinoRun = DinoRun();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  await initHive();
  runApp(DinoRunApp());
}

Future<void> initHive() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  Hive.registerAdapter<PlayerData>(PlayerDataAdapter());
  Hive.registerAdapter<Settings>(SettingsAdapter());
}

class DinoRunApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dino Run',
      theme: ThemeData(
        fontFamily: 'Audiowide',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            minimumSize: Size(200, 60),
          ),
        ),
      ),
      home: Scaffold(
        body: GameWidget(
          loadingBuilder: (conetxt) => Center(
            child: Container(
              child: CircularProgressIndicator(),
            ),
          ),
          overlayBuilderMap: {
            MainMenu.id: (_, DinoRun gameRef) => MainMenu(gameRef),
            PauseMenu.id: (_, DinoRun gameRef) => PauseMenu(gameRef),
            Hud.id: (_, DinoRun gameRef) => Hud(gameRef),
            GameOverMenu.id: (_, DinoRun gameRef) => GameOverMenu(gameRef),
          },
          initialActiveOverlays: [MainMenu.id],
          game: _dinoRun,
        ),
      ),
    );
  }
}
