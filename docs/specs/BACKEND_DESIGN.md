# BACKEND_DESIGN.md - Backend Service Design

---
title: 썸썸 (Thumb Some) - Backend Design
version: 1.0.0
status: Approved
---

## Current (MVP)

**No backend** - All logic runs locally on device.

## Phase 2: Firebase Integration

### Services

**1. Firebase Analytics**
- Track user behavior
- Events: game_start, game_complete, game_fail, share_result
- Custom parameters: mode, duration, success, difficulty

**2. Firebase Crashlytics**
- Automatic crash reporting
- Custom logs for debugging
- User properties: device, OS version

**3. Firebase Remote Config**
- Dynamic game configuration
- A/B testing support
- Configuration:
  ```json
  {
    "game_duration_seconds": 15,
    "intensity_scale": 2.0,
    "touch_tolerance": 60.0,
    "soul_sync_questions": [...],
    "feature_flags": {
      "soul_sync_enabled": true,
      "penalty_roulette_enabled": false
    }
  }
  ```

### Implementation

```dart
// lib/core/services/firebase_service.dart

class FirebaseService {
  final FirebaseAnalytics analytics;
  final FirebaseCrashlytics crashlytics;
  final FirebaseRemoteConfig remoteConfig;

  Future<void> initialize() async {
    await Firebase.initializeApp();
    await remoteConfig.fetchAndActivate();
  }

  Future<void> logEvent(String name, Map<String, dynamic> params) async {
    await analytics.logEvent(name: name, parameters: params);
  }

  Future<GameConfig> getGameConfig() async {
    return GameConfig(
      duration: remoteConfig.getInt('game_duration_seconds'),
      intensityScale: remoteConfig.getDouble('intensity_scale'),
      touchTolerance: remoteConfig.getDouble('touch_tolerance'),
    );
  }
}
```

## Phase 3: Cloud Functions (Optional)

**Leaderboard API**:
```
POST /api/leaderboard
GET  /api/leaderboard/top100
```

**User Profile**:
```
GET  /api/user/:id
PUT  /api/user/:id
```

See [API_SPEC.md](./API_SPEC.md) for API details.
See [ARCHITECTURE.md](./ARCHITECTURE.md) for architecture.
