# FRONTEND_SPEC.md - Frontend Specification

---
title: 썸썸 (Thumb Some) - Frontend Specification
version: 1.0.0
status: Approved
---

## UI Components

### Design System (TDS)

**Colors**:
The application uses a Material Design 3 (M3) theme. The entire color palette is algorithmically generated from a single seed color.

- **Seed Color Source**: Salesforce Lightning Design System
- **Seed Color**: `#0176D3` (Salesforce Blue)

**Typography**:
```dart
titleBig:    28px, Bold, -0.5 spacing
titleMedium: 22px, Bold, -0.5 spacing  
body:        16px, Medium, -0.2 spacing
```

**Animation**: Spring curve (Curves.elasticOut)

### Screens

**1. IntroScreen** (`lib/features/intro/intro_screen.dart`)
- Landing page
- Animated title with pulsing hearts
- "쫀드기 챌린지 시작하기" button
- Toss-style layout

**2. GameScreen** (`lib/features/sticky_fingers/game_screen.dart`)
- Multi-touch game area (full screen)
- Progress indicator (0-100%)
- Character emojis (🐻 곰, 🐰 토끼)
- Real-time position tracking via CustomPainter
- Success/Fail overlay modals

**3. SoulSyncScreen** (Phase 2)
- Split screen (180° rotated)
- Question cards (20 questions)
- O/X buttons
- Compatibility score result

### Widgets

**TossButton**:
```dart
Container(
  height: 56,
  decoration: BoxDecoration(
    color: TDS.primaryBlue,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Text(text, style: bold white 17px),
)
```

**FadeInUp**:
- Entry animation
- Spring curve
- Configurable delay

**GamePainter** (CustomPainter):
- Draws characters (🐻, 🐰)
- Draws connection line between fingers
- Draws glow effects
- 60fps rendering

## Responsive Design

**Minimum Screen**: iPhone SE (4.7", 375x667)
**Maximum Screen**: iPad Pro (12.9", 1024x1366)

**Layout Strategy**: Relative positioning via MediaQuery
- All positions calculated from screen center
- Touch tolerance scales with screen size

See [ARCHITECTURE.md](./ARCHITECTURE.md) for component structure.
