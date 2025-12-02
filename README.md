# 썸썸 (Thumb Some) 👆💕👆

> **"게임인 척하며 자연스럽게 손잡기"**

손끝으로 전해지는 찌릿한 시그널, 스마트폰이라는 좁은 공간을 두 사람이 공유하게 만들어 물리적 접촉을 '게임의 필수 요소'로 강제하는 하이퍼 캐주얼 소셜 인터랙티브 앱.

---

## Pain Point & Solution

| Pain Point | Solution |
|------------|----------|
| 썸 단계나 소개팅, 술자리에서 스킨십 진도를 나가고 싶지만 명분이 없어 어색함 | 스마트폰 화면을 함께 터치해야 하는 게임으로 스킨십을 '필수 요소'로 만듦 |
| 직접적인 스킨십 요청은 부담스러움 | B급 감성과 웃음 코드로 민망함을 해소 |

---

## Design Concept

### Material Design 3 (M3) + Kitsch

**Base:** Material Design 3의 체계적인 색상 생성과 접근성 준수

**Seed Color:** 네온 핑크 `#FF007F` (kitschPink)를 시드로 M3 tonal palette 자동 생성

```
┌──────────────────────────────────────────────────┐
│  M3 Color System (Seed: kitschPink #FF007F)      │
│  ─────────────────────────────────────────────── │
│  Primary:    kitschPink 기반 tonal palette       │
│  Secondary:  M3 알고리즘 자동 생성                │
│  Surface:    M3 dark surface tokens              │
│  Theme:      Dark mode only (Brightness.dark)    │
└──────────────────────────────────────────────────┘
```

### Tone & Manner
- **텍스트:** "띠로리~", "천생연분!", "어머! 닿겠어!" 등 밈(Meme) 활용
- **사운드:** 상황에 딱 맞는 효과음 위주
- **모션 (하이브리드):**
  - 일반 UI: M3 easing (`Easing.emphasizedDecelerate`)
  - 게임 피드백: `Curves.elasticOut` (쫀득한 느낌)

---

## Features

### Mode A: 쫀드기 챌린지 (Sticky Fingers) - MVP Core

두 사람이 각자 캐릭터(🐻곰, 🐰토끼)를 손가락으로 누르고, 움직이는 캐릭터를 놓치지 않고 15초간 버티는 게임.

**Game Logic:**
1. 두 유저가 각각 캐릭터를 터치 → 게임 시작
2. 캐릭터가 화면을 불규칙하게 돌아다님 (속도 점진적 증가)
3. 두 캐릭터의 이동 경로가 **8자** 혹은 **나선형**으로 꼬이도록 설계
4. 유저의 팔이 교차(Cross)되거나 어깨가 닿게 유도

**Level Design:**
| Level | 설명 | 스킨십 강도 |
|-------|------|-----------|
| Lv 1 (탐색전) | 느린 속도, 동선 겹침 없음 | 손가락만 닿음 |
| Lv 2 (접촉 사고) | 속도 증가, 중앙에서 자주 만남 | 손등이 닿음 |
| Lv 3 (밀착) | 캐릭터가 화면 구석으로 이동 후 급격히 교차 | 팔/어깨 밀착 필수 |

**Fail Condition:** 손가락을 떼거나 화면 밖으로 이탈 시

**Feedback:**
- ✅ 성공: `HapticFeedback.vibrate()` + 폭죽 애니메이션 + "천생연분!"
- ❌ 실패: `HapticFeedback.heavyImpact()` + "띠로리~" + 벌칙 안내

### Mode B: 이심전심 텔레파시 (Soul Sync) ✅

두 사람이 마주보고 각자 영역에서 같은 질문에 O/X로 답하며 궁합 테스트

**Game Logic:**
1. 화면이 50:50으로 상하 분할, 상단 영역은 180° 회전 (대면 플레이용)
2. 10개 질문 풀에서 5개 랜덤 선택
3. 양쪽 모두 답변 시 자동으로 다음 질문 전환
4. 결과에 따라 3단계 멘트: "천생연분!" (≥80%) / "꽤 맞네?" (50-79%) / "이건 좀..." (<50%)

**Feedback:**
- ✅ 80%+ : `HapticFeedback.vibrate()` + 🎉 + M3 primary 색상
- 😊 50-79%: `HapticFeedback.mediumImpact()` + M3 tertiary 색상
- 😅 <50%: `HapticFeedback.lightImpact()` + M3 onSurfaceVariant 색상

### Mode C: 복불복 룰렛 (Penalty) - *Coming Soon*

벌칙 전용 룰렛 (커스텀 입력 가능)
- 기본 프리셋: "러브샷 하기", "소원 들어주기", "10초간 포옹"

---

## Tech Stack

| 구분 | 기술 | 선정 이유 |
|------|------|----------|
| Framework | Flutter 3.x | 단일 코드베이스 iOS/Android, 60fps 보장 |
| State Mgt | Riverpod (예정) | Provider보다 안전한 상태 관리 |
| Graphics | CustomPainter | 캔버스 직접 드로잉으로 퍼포먼스 최적화 |
| Animation | FadeInUp (Custom) | TDS 스타일 쫀득한 진입 애니메이션 |
| Haptic | flutter/services | 터치 반응 속도 중요 |

---

## Getting Started

### Prerequisites
- Flutter 3.x 이상
- Dart SDK

### Installation

```bash
# 클론
git clone https://github.com/your-repo/thumb-some.git
cd thumb-some

# 의존성 설치
flutter pub get

# 실행
flutter run
```

### Project Structure

```
thumb-some/
├── lib/
│   └── main.dart          # 전체 앱 코드 (Single File Architecture)
│       ├── ThemeData      # M3 ColorScheme.fromSeed()
│       ├── IntroScreen    # 메인 로비
│       ├── GameScreen     # 쫀드기 챌린지 게임
│       ├── SoulSyncScreen # 이심전심 텔레파시 게임
│       ├── GamePainter    # CustomPainter 그래픽
│       └── FadeInUp       # 진입 애니메이션
├── specs/                 # 기능 명세 (SpecKit)
└── README.md
```

---

## Developer's Note

### M3 (Material Design 3) 적용 포인트

1. **Color:** `ColorScheme.fromSeed(seedColor: kitschPink, brightness: Brightness.dark)`로 전체 팔레트 자동 생성
2. **Motion (하이브리드):**
   - 일반 UI: M3 easing curves (`Easing.emphasizedDecelerate`, `Easing.standard`)
   - 게임 피드백: `Curves.elasticOut` 유지 (쫀득한 느낌)
3. **Components (하이브리드):**
   - 표준 UI: Flutter M3 위젯 (`FilledButton`, `Card`)
   - 게임 UI: 커스텀 구현 (O/X 버튼, 결과 카드)
4. **UX:** 복잡한 튜토리얼 없이 직관적인 행동 유도성(Affordance) 디자인

### 쫀드기 챌린지 알고리즘

```dart
// Sin/Cos 조합으로 8자 경로 유도
targetA = Offset(
  centerX - 80 + sin(_time * 1.5) * 60 * intensity,
  centerY + cos(_time * 2.1) * 100 * intensity,
);

targetB = Offset(
  centerX + 80 + cos(_time * 1.8) * 60 * intensity,  // 반대 위상
  centerY + sin(_time * 2.4) * 100 * intensity,
);
```

### Performance Optimization

- `CustomPainter`와 `Ticker`를 직접 제어하여 60fps(또는 120fps) 부드러운 움직임 보장
- `shouldRepaint` 최적화로 불필요한 리페인트 방지

---

## Roadmap

- [x] MVP: 쫀드기 챌린지 기본 로직
- [x] M3 디자인 시스템 (Constitution v2.0)
- [x] 햅틱 피드백
- [x] 이심전심 텔레파시 모드
- [ ] M3 테마 코드 마이그레이션 (TDS → ColorScheme)
- [ ] 복불복 룰렛 모드
- [ ] Firebase 연동 (질문 리스트 Remote Config)
- [ ] 결과 화면 공유 (인스타 스토리용 영수증 디자인)
- [ ] In-App Purchase (화끈한 매운맛 팩)

---

## Target User

- 2030 남녀
- 썸 초기 단계
- 소개팅/술자리 아이스브레이킹 필요

---

## Use Case

> "내가 이거 개발했는데 테스트 좀 해줄래?"

썸남/썸녀에게 자연스럽게 접근하는 멘트로 활용 가능 (개발자 한정)

---

## License

MIT License

---

*"진지함은 빼고, 스킨십은 더하고!"* 💕
