# API_SPEC.md - API Specification

---
title: 썸썸 (Thumb Some) - API Specification  
version: 1.0.0
status: Approved
---

## Summary

**Current (MVP)**: No external APIs - Local only
**Phase 2**: Firebase APIs (Analytics, Crashlytics, Remote Config)

## Firebase APIs (Phase 2)

### Analytics Events

```dart
// Game Start
analytics.logEvent(
  name: 'game_start',
  parameters: {
    'mode': 'sticky_fingers',
    'screen_size': '${width}x${height}',
  },
);

// Game Complete
analytics.logEvent(
  name: 'game_complete',
  parameters: {
    'mode': 'sticky_fingers',
    'success': true,
    'duration': 15.2,
    'difficulty': 'normal',
  },
);
```

### Remote Config

```dart
// Fetch game configuration
final config = FirebaseRemoteConfig.instance;
await config.fetchAndActivate();

final gameDuration = config.getInt('game_duration') ?? 15;
final intensityScale = config.getDouble('intensity_scale') ?? 2.0;
```

See [BACKEND_DESIGN.md](./BACKEND_DESIGN.md) for details.
