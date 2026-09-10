# Retro Snake

A Nokia-3310-style Snake game built with Flutter: yellow-green LCD look,
grid-based movement, swipe + on-screen D-pad controls, speeds up as you
score, and remembers your high score on-device.

## Project structure

```
lib/
  main.dart                 # App entry point + theme
  game/snake_game.dart      # Game rules (grid, movement, collisions, scoring)
  widgets/game_board.dart   # CustomPainter that draws the retro LCD screen
  screens/home_screen.dart  # Title screen
  screens/game_screen.dart  # Gameplay screen (loop, controls, overlays)
```

## Run it locally

You'll need the Flutter SDK installed: https://docs.flutter.dev/get-started/install

```bash
cd retro_snake
flutter pub get
flutter run
```

Pick a connected device/emulator when prompted, or run `flutter run -d chrome`
to try it in a browser first — the whole game works fine on web for quick
iteration before you touch a phone.

## Customizing

- **Colors**: the classic palette lives as hex constants (`0xFF9BBC0F` light
  green, `0xFF0F1A0F` dark green) in `game_board.dart`, `home_screen.dart`,
  and `game_screen.dart`. Change those to re-theme it.
- **Grid size / difficulty**: `SnakeGame(columns: 17, rows: 27)` in
  `game_screen.dart`, and the speed curve in `SnakeGame.tickDuration`.
- **Sound**: not included yet. Easiest option is the `audioplayers` package —
  add a short "beep" on eating food and a "crash" on game over.

## Publishing to the App Store (iOS)

1. You need a Mac with Xcode, and an active Apple Developer account ($99/yr).
2. Set your bundle identifier and app name in `ios/Runner.xcodeproj` (or via
   `flutter create --org com.yourcompany .` before you start, which sets it
   everywhere at once).
3. Generate a proper app icon — the
   [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)
   package will generate all required sizes from one source image.
4. Build: `flutter build ipa`
5. Upload the resulting `.ipa` via Xcode Organizer or
   `xcrun altool`/Transporter to App Store Connect.
6. Fill out the App Store Connect listing (screenshots, description,
   age rating, privacy info) and submit for review.

Full walkthrough: https://docs.flutter.dev/deployment/ios

## Publishing to Google Play (Android)

1. Create a Google Play Developer account ($25 one-time).
2. Set your application ID in `android/app/build.gradle` (`applicationId`).
3. Generate an upload keystore and configure signing — Flutter's docs cover
   this step by step.
4. Build an app bundle: `flutter build appbundle`
5. Upload the `.aab` from `build/app/outputs/bundle/release/` to the Play
   Console, fill out the store listing, and roll out to testing/production.

Full walkthrough: https://docs.flutter.dev/deployment/android

## Suggested next steps

- Add a short beep/crunch sound effect on eating food and game over.
- Add haptic feedback (`HapticFeedback.lightImpact()`) on direction changes.
- Add a simple settings screen for grid size / difficulty.
- Wrap `shared_preferences` calls with a proper local leaderboard if you want
  more than a single high score.
