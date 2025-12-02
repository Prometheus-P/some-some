# Claude.md - AI Development Context Guide

## Project Overview

**Project Name:** 썸썸 (Thumb Some) 👆💕👆
**Tagline:** "게임인 척하며 자연스럽게 손잡기"
**Type:** Flutter-based Hyper-Casual Social Interactive App
**Target Users:** 20-30대 남녀 (썸 초기 단계, 소개팅/술자리)

### Core Concept
A mobile game that **forces physical contact as a game mechanic**. Two users must touch and hold moving characters on a shared smartphone screen for 15 seconds, creating natural skinship through gameplay.

---

## Current Implementation Status

### ✅ Completed (MVP)
- **Single-file architecture** (`main.dart`) - intentionally monolithic for rapid prototyping
- **쫀드기 챌린지 (Sticky Fingers)** core game logic
- **Material Design 3 (M3)** with kitschPink seed color theme
- **이심전심 텔레파시 (Soul Sync)** compatibility quiz mode
- **CustomPainter** for 60fps+ graphics rendering
- **Haptic feedback** system (light/medium/heavy impacts)
- **FadeInUp** animations with hybrid motion (M3 easing + elasticOut)
- **Multi-touch** detection and tracking

### ⏳ Planned Features (Not Implemented)
- **Mode C:** 복불복 룰렛 (Penalty Roulette) - customizable penalty roulette
- **M3 Theme Migration:** Apply M3 ColorScheme to existing TDS code
- **Firebase integration** for remote question lists
- **Result sharing** (Instagram story-style receipts)
- **In-App Purchase** for additional content packs

---

## Architecture Principles

### 1. File Structure Philosophy
**Current:** Single-file MVP (`main.dart`)
**Future:** When complexity grows, split into:
```
lib/
├── main.dart
├── core/
│   ├── design_system/
│   │   └── tds.dart
│   └── utils/
├── features/
│   ├── intro/
│   ├── sticky_fingers/
│   ├── soul_sync/
│   └── penalty_roulette/
└── shared/
    └── widgets/
```

**⚠️ Rule:** Only refactor into modules **when adding Mode B or C**. Keep current simplicity for now.

### 2. Design System (M3)

**Base:** Material Design 3 with custom kitschPink seed color

**Color System (M3 Tonal Palette):**
- **Seed Color:** `kitschPink (#FF007F)` generates full tonal palette
- **Primary:** kitschPink-derived tones (primary, onPrimary, primaryContainer)
- **Secondary/Tertiary:** M3 algorithm auto-generated
- **Surface:** M3 dark surface tokens
- **Theme Mode:** Dark only (`Brightness.dark`)

**Implementation:**
```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFFFF007F), // kitschPink
    brightness: Brightness.dark,
  ),
)
```

**Typography:** M3 type scale via `TextTheme`, Korean-optimized font

**Motion (Hybrid):**
- **General UI:** M3 easing (`Easing.emphasizedDecelerate`, `Easing.standard`)
- **Game Feedback:** `Curves.elasticOut` retained for "쫀득한" feel

**Components (Hybrid):**
- **Standard UI:** Flutter M3 widgets (`FilledButton`, `Card`)
- **Game UI:** Custom implementation (O/X buttons, result cards)

**⚠️ Rule:** All new UI MUST use M3 color tokens from `Theme.of(context).colorScheme`.

### 3. Game Logic - Sticky Fingers Algorithm

**Target Movement (8-figure path):**
```dart
// Sin/Cos combination creates crossing paths
targetA = Offset(
  centerX - 80 + sin(_time * 1.5) * 60 * intensity,
  centerY + cos(_time * 2.1) * 100 * intensity,
);

targetB = Offset(
  centerX + 80 + cos(_time * 1.8) * 60 * intensity,  // Opposite phase
  centerY + sin(_time * 2.4) * 100 * intensity,
);
```

**Physics Parameters:**
- `gameDuration: 15.0` seconds
- `targetRadius: 45.0` (visual circle)
- `touchTolerance: 60.0` (hit detection)
- `intensity: 1.0 + (progress * 2.0)` (difficulty scaling)

**⚠️ Rule:** Don't change physics constants without playtesting. Current values are carefully balanced.

### 4. Performance Optimization

**Critical Requirements:**
- Maintain **60fps minimum** (120fps preferred on ProMotion displays)
- Use `Ticker` directly, not `AnimationController` for game loop
- `CustomPainter.shouldRepaint` always returns `true` (intentional - game state changes every frame)

**⚠️ Rule:** Profile performance before/after ANY game loop changes.

---

## Development Guidelines

### Code Style

1. **Dart Formatting:**
   - Use `dart format` before commits
   - Line length: 120 characters (not 80)
   - Prefer expression bodies for single-line getters

2. **Naming Conventions:**
   - Private variables: `_camelCase`
   - Constants: `camelCase` (not SCREAMING_SNAKE)
   - Widget classes: `PascalCase`

3. **Comments:**
   - Korean OK for domain-specific terms (e.g., `// 쫀드기 로직`)
   - English for generic programming concepts
   - Use section dividers like `// -----------------------------------------------------------------------------`

### Testing Strategy

**Current:** Manual testing only (acceptable for MVP)
**Future:** When adding new modes:
- Unit tests for game logic (collision detection, timer)
- Widget tests for UI components
- Integration tests for full game flow

**⚠️ Rule:** Don't write tests for current MVP unless bugs appear in production.

### Git Workflow

1. **Branch naming:** `claude/feature-name-{sessionId}`
2. **Commit style:**
   ```
   feat: add soul sync mode basic UI
   fix: prevent game start with single touch
   refactor: extract game logic from widget
   ```
3. **Always commit working code** (playable state)

---

## Common Tasks & Solutions

### Adding a New Game Mode

1. Create new screen widget (e.g., `PenaltyRouletteScreen`)
2. Add navigation button in `IntroScreen`
3. Design game logic with similar structure to `GameScreen`:
   - State management
   - Touch handling
   - Game loop (if needed)
   - Result overlay
4. Use M3 widgets (`FilledButton`) and `Theme.of(context).colorScheme` for colors
5. Reuse `FadeInUp` animation with hybrid motion approach

### Tweaking Game Difficulty

**Easier:**
- Increase `touchTolerance` (60 → 80)
- Decrease `intensity` multiplier (2.0 → 1.5)
- Reduce movement speed (multiply frequency values by 0.8)

**Harder:**
- Add sudden direction changes
- Increase `gameDuration` (15 → 20 seconds)
- Make targets smaller (`targetRadius: 45 → 35`)

### Adding Haptic Patterns

Available methods:
- `HapticFeedback.lightImpact()` - subtle (e.g., heartbeat)
- `HapticFeedback.mediumImpact()` - standard (e.g., button tap)
- `HapticFeedback.heavyImpact()` - strong (e.g., game start/fail)
- `HapticFeedback.vibrate()` - celebration (success state)

**⚠️ Rule:** Test on physical device. Haptics don't work in simulator.

### Handling Screen Sizes

**Current approach:** Relative positioning via `MediaQuery.of(context).size`
**Safe area:** Already handled with `SafeArea` widget in `IntroScreen`
**Notch handling:** Implicit via Flutter's safe area

**⚠️ Rule:** Test on both small (iPhone SE) and large (iPad) screens before release.

---

## Known Issues & Limitations

### Current Bugs
None reported (MVP just completed)

### Technical Debt
1. **Hard-coded initial positions:** `targetA = Offset(100, 400)` should use screen dimensions
2. **No state persistence:** Exiting game loses progress (acceptable for MVP)
3. **Single-threaded physics:** Game loop blocks UI thread (acceptable at 60fps)

### Platform-Specific Issues
- **iOS:** Requires `Info.plist` permission for haptics (already added)
- **Android:** May need `VIBRATE` permission check (TODO)

---

## Communication Style & UX Copy

### Voice & Tone
- **Casual Korean slang:** "띠로리~", "천생연분!", "어머! 닿겠어!"
- **B-grade sensibility:** Intentionally cheesy/kitsch
- **No formality:** Never use 존댓말 (polite form)

### Example Copy Patterns
```
✅ Good: "이 정도면 사귀어야 하는 거 아님?"
❌ Bad: "축하드립니다. 게임을 완료하셨습니다."

✅ Good: "손을 놓쳐버렸어요!"
❌ Bad: "터치가 감지되지 않았습니다."
```

**⚠️ Rule:** Keep the playful, slightly cringey vibe. This is a feature, not a bug.

---

## Dependencies & Environment

### Current `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  # No external packages yet (intentional)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

**⚠️ Rule:** Only add dependencies when **absolutely necessary**. Prefer built-in Flutter APIs.

### Planned Additions
- `riverpod: ^2.x` - State management (when adding Mode B/C)
- `firebase_core` - Backend integration
- `share_plus` - Social sharing
- `in_app_purchase` - Monetization

---

## AI Development Guidelines (For Claude)

### When Working on This Project:

1. **Read first, code second:** Always check existing implementation before suggesting changes
2. **Respect the vibe:** Maintain the playful, B-grade aesthetic
3. **Test on device:** Remind user to test haptics/multi-touch on physical hardware
4. **Ask before refactoring:** Don't break up `main.dart` unless user requests it
5. **Korean OK:** Use Korean in comments for domain terms, English for technical concepts
6. **Performance matters:** 60fps is non-negotiable for game feel

### When User Requests Are Ambiguous:

1. **Default to simplicity:** Don't over-engineer
2. **Match existing patterns:** Use M3 widgets, `Theme.of(context).colorScheme`, FadeInUp
3. **Preserve game feel:** Don't change physics without explicit ask

### When Adding New Features:

1. Confirm requirements first
2. Show code diff for critical sections (game loop, physics)
3. Warn about performance implications if adding heavy operations
4. Suggest testing checklist

---

## Quick Reference

### File Locations
- Main app: `main.dart` (all code)
- README: `README.md` (Korean docs)
- Assets: None yet (all using emojis)

### Key Classes
- `ThemeData` with M3 - Design system via `ColorScheme.fromSeed()`
- `IntroScreen` - Landing page
- `GameScreen` - Sticky Fingers game logic
- `SoulSyncScreen` - Soul Sync quiz game
- `GamePainter` - Canvas rendering
- `FadeInUp` - Entrance animation (hybrid motion)

### Build & Run
```bash
flutter pub get
flutter run
```

### Useful Commands
```bash
dart format .                    # Format code
flutter analyze                  # Lint check
flutter build apk --release      # Android build
flutter build ios --release      # iOS build
```

---

## Contact & Resources

- **Design Reference:** Material Design 3 (m3.material.io), Duolingo (playful UX)
- **Game Feel Reference:** Crossy Road, Monument Valley (haptic timing)
- **Target Benchmark:** 60fps on iPhone 12, 120fps on iPhone 15 Pro

---

**Last Updated:** 2025-12-02
**Document Version:** 2.0
**Project Phase:** Soul Sync Complete, M3 Migration In Progress

## Active Technologies
- Dart 3.x / Flutter 3.x + Flutter SDK only (no external packages per Constitution) (001-soul-sync)
- N/A (in-memory game state, hardcoded question list for MVP) (001-soul-sync)

## Recent Changes
- 001-soul-sync: Added Dart 3.x / Flutter 3.x + Flutter SDK only (no external packages per Constitution)
