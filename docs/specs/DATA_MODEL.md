# DATA_MODEL.md - Data Model Specification

---
title: 썸썸 (Thumb Some) - Data Model
version: 1.0.0  
status: Approved
---

## Local Storage (SharedPreferences)

### Game State

```dart
class GameState {
  final GameStatus status;       // idle, playing, success, failure
  final double progress;          // 0.0 - 1.0
  final Offset targetA;
  final Offset targetB;
  final Map<int, Offset> pointers;
  final double elapsedTime;
}
```

### Game Result

```dart
class GameResult {
  final String id;
  final String mode;              // 'sticky_fingers', 'soul_sync', etc.
  final bool success;
  final double duration;
  final DateTime timestamp;
  final String? player1Name;
  final String? player2Name;
}
```

### User Preferences

```dart
class UserPreferences {
  final bool hapticEnabled;
  final bool soundEnabled;  
  final String difficulty;        // 'easy', 'normal', 'hard'
  final List<String> customPenalties;
}
```

## Firebase (Phase 2)

### Analytics Events
- Stored in Firebase Analytics (auto-managed)
- No schema needed

### Remote Config
- JSON configuration
- No local storage

See [ARCHITECTURE.md](./ARCHITECTURE.md) for entity definitions.
