<!--
SYNC IMPACT REPORT
==================
Version change: 1.0.0 → 2.0.0 (MAJOR - Principle III redefinition)
Modified principles:
  - III. Design System Compliance (TDS) → III. Design System Compliance (M3)
Added sections: None
Removed sections: None
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ (no TDS references - compatible)
  - .specify/templates/spec-template.md ✅ (no TDS references - compatible)
  - .specify/templates/tasks-template.md ✅ (no TDS references - compatible)
  - .specify/templates/checklist-template.md ✅ (no TDS references - compatible)
  - .specify/templates/agent-file-template.md ✅ (no TDS references - compatible)
Files requiring manual follow-up (contain TDS references):
  - lib/main.dart ⚠ (implementation code - requires M3 migration task)
  - Claude.md ⚠ (runtime guidance - update TDS section to M3)
  - specs/001-soul-sync/plan.md ⚠ (feature plan - update design system references)
  - README.md ⚠ (documentation - update design system description)
Follow-up TODOs:
  - Create M3 migration implementation task for lib/main.dart
  - Update CLAUDE.md design system section
-->

# 썸썸 (Thumb Some) Constitution

## Core Principles

### I. Simplicity First

Every feature starts as the simplest possible implementation. The current single-file MVP architecture (`main.dart`) is intentional and MUST NOT be split into modules until adding Mode B (이심전심 텔레파시) or Mode C (복불복 룰렛) explicitly requires it.

**Rules:**
- MUST prefer editing existing code over creating new files
- MUST NOT add abstractions, helpers, or utilities for one-time operations
- MUST NOT design for hypothetical future requirements (YAGNI)
- MUST NOT add external dependencies unless absolutely necessary—prefer built-in Flutter APIs

**Rationale:** Complexity is the enemy of rapid iteration. Premature abstraction creates maintenance burden without immediate value.

### II. Performance Non-Negotiable

The game MUST maintain 60fps minimum (120fps on ProMotion displays). This is not a nice-to-have—it directly affects the "쫀득한" (chewy) feel that defines the user experience.

**Rules:**
- MUST use `Ticker` directly for game loops, not `AnimationController`
- MUST profile performance before AND after any game loop changes
- MUST test on physical devices, not simulators (especially for haptics)
- `CustomPainter.shouldRepaint` returns `true` intentionally—do not "optimize" this

**Rationale:** Frame drops destroy the tactile illusion. Users will feel the difference even if they can't articulate it.

### III. Design System Compliance (M3)

All UI MUST follow Material Design 3 with a custom theme derived from the kitschPink seed color. This replaces the previous TDS (Toss Design System) approach.

**Color System (M3 Tonal Palette):**
- Seed color: `kitschPink (#FF007F)` generates full M3 tonal palette
- Primary: kitschPink-derived tones (primary, onPrimary, primaryContainer, etc.)
- Secondary/Tertiary: M3 algorithm auto-generated from seed
- Surface: M3 dark surface tokens (`surface`, `surfaceVariant`, `onSurface`)
- Theme mode: Dark only (`Brightness.dark`)

**Typography:** M3 type scale via `TextTheme`, Korean-optimized font

**Motion (Hybrid):**
- General UI: M3 easing curves (`Easing.emphasizedDecelerate`, `Easing.standard`)
- Game feedback: `Curves.elasticOut` retained for "쫀득한" feel

**Components (Hybrid):**
- Standard UI: Flutter M3 widgets (`FilledButton`, `Card`, `NavigationBar`)
- Game UI: Custom implementation (O/X buttons, result cards, PlayerArea)

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

**Rationale:** M3 provides systematic color generation, accessibility compliance (WCAG contrast ratios), and modern Flutter integration while preserving brand identity through the kitschPink seed.

### IV. Physics Stability

Game physics constants have been carefully playtested and balanced. Changes require explicit user request AND playtesting on a physical device.

**Protected Constants:**
- `gameDuration: 15.0` seconds
- `targetRadius: 45.0`
- `touchTolerance: 60.0`
- `intensity: 1.0 + (progress * 2.0)`

**Rules:**
- MUST NOT change physics values without playtesting
- MUST NOT alter the sin/cos movement algorithm without explicit request
- MUST document difficulty changes with before/after comparison

**Rationale:** Game feel is fragile. Small changes compound into dramatically different experiences.

### V. Brand Voice Authenticity

The B-grade, kitsch aesthetic is a feature, not a bug. All user-facing copy MUST maintain casual Korean slang and intentional cheesiness.

**Rules:**
- MUST use 반말 (casual speech), NEVER 존댓말 (formal speech)
- MUST prefer playful phrases: "띠로리~", "천생연분!", "어머! 닿겠어!"
- MUST NOT use corporate/formal language: "축하드립니다", "완료하셨습니다"
- Korean OK in code comments for domain-specific terms

**Rationale:** The target users (20-30대 in 썸 situations) respond to relatable, slightly embarrassing energy. Over-professionalism kills the vibe.

## UX & Brand Constraints

**Device Testing Mandate:**
- Haptic feedback (`HapticFeedback.*`) MUST be tested on physical devices
- Multi-touch interactions MUST be tested with actual two-person gameplay
- Screen size edge cases MUST be validated on iPhone SE (small) and iPad (large)

**Safe Area & Screen Handling:**
- All screens MUST use `SafeArea` widget
- Target positions MUST use `MediaQuery.of(context).size`, not hard-coded offsets
- Known debt: initial target positions are hard-coded (acceptable for MVP, fix before Mode B)

**Haptic Patterns:**
- `lightImpact()` → subtle feedback (heartbeat pulse)
- `mediumImpact()` → standard feedback (button tap)
- `heavyImpact()` → strong feedback (game start/fail)
- `vibrate()` → celebration (success state only)

## Development Workflow

**Git & Commits:**
- Branch naming: `claude/feature-name-{sessionId}` or `NNN-feature-name`
- Commit messages: `feat:`, `fix:`, `refactor:` prefixes
- MUST commit only working (playable) code
- MUST NOT commit code that hasn't been verified on device for haptic/multi-touch features

**Code Style:**
- `dart format` before all commits
- Line length: 120 characters
- Private variables: `_camelCase`
- Constants: `camelCase` (not SCREAMING_SNAKE)
- Comments: Korean OK for domain terms, English for technical concepts

**Testing Strategy (MVP Phase):**
- Manual testing is acceptable and sufficient
- Unit/widget tests MUST NOT be added unless bugs appear in production
- Test additions require explicit user request

**Refactoring Policy:**
- MUST ask before splitting `main.dart`
- MUST NOT refactor during feature implementation unless explicitly requested
- Complexity additions MUST be justified in the plan document

## Governance

This constitution supersedes all other development practices for this project. All PRs, code reviews, and implementation decisions MUST verify compliance with these principles.

**Amendment Procedure:**
1. Propose change with rationale
2. Document impact on existing code
3. Update constitution version
4. Update dependent templates if affected

**Versioning Policy:**
- MAJOR: Principle removal or backward-incompatible redefinition
- MINOR: New principle or materially expanded guidance
- PATCH: Clarifications, wording, non-semantic refinements

**Compliance Review:**
- Every feature plan MUST include a Constitution Check section
- Violations MUST be explicitly justified in the Complexity Tracking table
- Runtime guidance in `CLAUDE.md` remains the primary development reference

**Version**: 2.0.0 | **Ratified**: 2025-12-02 | **Last Amended**: 2025-12-02
