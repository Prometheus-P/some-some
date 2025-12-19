# Claude.md - AI Development Context Guide

## Project Overview

**Project Name:** 썸썸 (Thumb Some)
**Tagline:** "게임인 척하며 자연스럽게 손잡기"
**Type:** Flutter-based Hyper-Casual Social Interactive App
**Target Users:** 20-30대 남녀 (썸 초기 단계, 소개팅/술자리)
**Version:** 0.3.0
**Copyright:** (c) 2025 Prometheus-P. All rights reserved.

### Core Concept
A mobile game that **forces physical contact as a game mechanic**. Two users must touch and hold moving characters on a shared smartphone screen for 15 seconds, creating natural skinship through gameplay.

---

## Current Implementation Status

### ✅ Completed
- **Modular architecture** (lib/app, core, design_system, features)
- **쫀드기 챌린지 (Sticky Fingers)** - 15초 터치 홀드 게임
- **이심전심 텔레파시 (Soul Sync)** - 호환성 퀴즈 모드
- **Material Design 3 (M3)** with kitschPink seed color theme
- **Design System** (tds.dart - typography, colors, motion)
- **Content Packs** system (동적 텍스트 로딩)
- **Settings** persistence (민감도, 배터리 세이버)
- **Result sharing** (스크린샷 공유)
- **Analytics** framework (텔레메트리)

### ⏳ Planned Features
- **Mode C:** 복불복 룰렛 (Penalty Roulette)
- **Firebase integration** for remote question lists
- **In-App Purchase** for additional content packs

---

## Architecture

### File Structure (Modular)
```
lib/
├── main.dart                    # Entry point only
├── app/
│   └── app.dart                 # ThumbSomeApp (MaterialApp config)
├── core/
│   ├── app_links.dart           # External URLs
│   ├── haptics/haptics.dart     # Haptic feedback
│   ├── packs/                   # Content pack system
│   ├── settings/                # User preferences
│   ├── share/                   # Screenshot sharing
│   └── telemetry/               # Analytics
├── design_system/
│   ├── tds.dart                 # Design tokens (colors, typography)
│   ├── components/              # Reusable widgets (TossButton)
│   └── motion/                  # Animations (FadeInUp)
└── features/
    ├── intro/                   # Landing screen
    ├── sticky_fingers/          # Main game
    └── soul_sync/               # Quiz game
```

### Flutter Design Patterns (필수 준수)

**1. State Management:**
- `StatefulWidget` + `ValueNotifier` for local state
- Game loop: `Ticker` with `ValueNotifier<double>` for progress
- Avoid `setState()` in game loops (use ValueListenableBuilder)

**2. Widget Composition:**
- Small, focused widgets (Single Responsibility)
- Extract reusable components to `design_system/components/`
- Use `const` constructors where possible

**3. Separation of Concerns:**
- UI logic: `features/` (screens, widgets)
- Business logic: `core/` (services, utilities)
- Presentation: `design_system/` (tokens, components)

**4. Dependency Injection:**
- Pass dependencies through constructors
- Use factory patterns for services (e.g., `PackLoader`, `SettingsStore`)

**5. Immutability:**
- Prefer immutable data classes
- Use `final` for fields, `const` for compile-time constants

---

## Design System (M3)

**Seed Color:** `kitschPink (#FF007F)`

```dart
ColorScheme.fromSeed(
  seedColor: Color(0xFFFF007F),
  brightness: Brightness.dark,
)
```

**Typography:** (from `tds.dart`)
- `titleBig(cs)` - 28pt bold
- `titleMedium(cs)` - 22pt bold
- `titleSmall(cs)` - 16pt semibold
- `bodyText(cs)` - 16pt medium
- `bodyBig(cs)` - 18pt medium
- `bodySmall(cs)` - 14pt regular

**Motion:**
- `kSpringCurve = Curves.elasticOut` - 게임 피드백용 "쫀득한" 느낌
- `FadeInUp` - 800ms, elasticOut curve

**Rule:** All UI MUST use `Theme.of(context).colorScheme` tokens.

---

## Development Guidelines

### TDD Cycle (필수)

**모든 새 기능은 TDD 사이클을 따름:**

1. **Red:** 실패하는 테스트 먼저 작성
   ```dart
   test('Soul Sync returns 천생연분 when match >= 80%', () {
     expect(getResultMessage(80), '천생연분!');
   });
   ```

2. **Green:** 테스트 통과하는 최소한의 코드 작성
   ```dart
   String getResultMessage(int percent) {
     if (percent >= 80) return '천생연분!';
     // ...
   }
   ```

3. **Refactor:** 코드 정리 (테스트 통과 유지)

**Test Categories:**
- `test/unit/` - 비즈니스 로직 (game logic, utilities)
- `test/widget/` - UI 컴포넌트 (isolated widget tests)
- `test/integration/` - 전체 플로우 (feature tests)

**Coverage Target:** 새 코드 80% 이상

### Code Style

1. **Dart Formatting:**
   - `dart format .` before commits
   - Line length: 120 characters

2. **Naming Conventions:**
   - Private: `_camelCase`
   - Constants: `camelCase`
   - Widgets: `PascalCase`

3. **Comments:**
   - Korean OK for domain terms (`// 쫀드기 로직`)
   - English for technical concepts

### Git Workflow

1. **Branch naming:** `feature/feature-name` or `fix/bug-name`

2. **Commit style (Co-Authored-By 없이):**
   ```
   feat: add penalty roulette mode
   fix: prevent game start with single touch
   refactor: extract game logic from widget
   test: add unit tests for match calculation
   ```

3. **PR Requirements:**
   - `flutter analyze` - 0 errors
   - `flutter test` - all passing
   - Code review approved

---

## Game Logic

### Sticky Fingers Physics
```dart
targetA = Offset(
  centerX - 80 + sin(_time * 1.5) * 60 * intensity,
  centerY + cos(_time * 2.1) * 100 * intensity,
);
```

- Duration: 15 seconds
- Target radius: 34px
- Touch tolerance: 60px
- Intensity: 1.0 + (progress * 2.0)

### Soul Sync Logic
- 5 questions from pool of 10
- Tiered results: ≥80% "천생연분!", ≥50% "꽤 맞네?", <50% "이건 좀..."

---

## Performance

**Requirements:**
- 60fps minimum (120fps on ProMotion)
- Use `Ticker` for game loop
- `CustomPainter.shouldRepaint` → `true`

**Optimization:**
- ValueNotifier instead of setState in loops
- RepaintBoundary for static elements
- Lazy loading for content packs

---

## Platform Configuration

### Android
- Package: `com.prometheusp.somesome`
- Min SDK: 21
- VIBRATE permission: ✅ Added

### iOS
- Bundle ID: `com.prometheusp.somesome`
- Display Name: 썸썸

---

## Commands

```bash
# Development
flutter pub get
flutter run

# Quality
dart format .
flutter analyze
flutter test

# Build
flutter build apk --release
flutter build ios --release
```

---

## UX Copy Style

**Voice:** Casual Korean slang, B-grade sensibility

```
✅ "이 정도면 사귀어야 하는 거 아님?"
❌ "축하드립니다. 게임을 완료하셨습니다."
```

---

**Last Updated:** 2025-12-19
**Document Version:** 3.0
**Project Phase:** Modular Architecture Complete
