# 썸썸 (Thumb Some) 👆💕👆

> **"게임인 척하며 자연스럽게 손 잡기"**

손끝으로 전해지는 찌릿한 시그널, 스마트폰이라는 좁은 공간을 두 사람이 공유하게 만들어 물리적 접촉을 '게임의 필수 요소'로 강제하는 하이퍼 캐주얼 소셜 인터랙티브 앱.

---

## Pain Point & Solution

| Pain Point | Solution |
|------------|----------|
| 썸 단계나 소개팅, 술자리에서 스킨십 진도를 나가고 싶지만 명분이 없어 어색함 | 스마트폰 화면을 함께 터치해야 하는 게임으로 스킨십을 '필수 요소'로 만듦 |
| 직접적인 스킨십 요청은 부담스러움 | B급 감성과 웃음 코드로 민망함을 해소 |

---

## Design Concept

### Toss Design System (TDS) + Kitsch

**Base:** 토스 앱의 신뢰감 있는 UX (직관성, 가독성, 부드러운 모션)

**Accent:** 네온 핑크 `#FF007F` & 옐로우 `#FFD700` 로 "이건 노는 거야!" 분위기 형성

```
┌──────────────────────────────────────┐
│  TDS.background   #17171C (다크 모드)  │
│  TDS.primaryBlue  #0064FF (토스 블루)  │
│  TDS.kitschPink   #FF007F (썸썸 핑크)  │
│  TDS.kitschYellow #FFD700 (썸썸 옐로우) │
└──────────────────────────────────────┘
```

### Tone & Manner
- **텍스트:** "띠로리~", "천생연분!", "어머! 닿겠어!" 등 밈(Meme) 활용
- **사운드:** 상황에 딱 맞는 효과음 위주
- **모션:** `SpringCurve`를 사용한 쫀득한 인터랙션

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

### Mode B: 이심전심 텔레파시 (Soul Sync) - *Coming Soon*

화면이 상하로 반전되어 분할, 질문에 O/X로 답하며 궁합 테스트

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
├── main.dart          # 전체 앱 코드 (Single File MVP)
│   ├── TDS            # Design System 상수
│   ├── IntroScreen    # 메인 로비
│   ├── GameScreen     # 쫀드기 챌린지 게임
│   ├── GamePainter    # CustomPainter 그래픽
│   ├── TossButton     # 토스 스타일 버튼
│   └── FadeInUp       # 진입 애니메이션
└── README.md
```

---

## Developer's Note

### TDS (Toss Design System) 적용 포인트

1. **Color:** 토스 블루(`#0064FF`)를 베이스로, 게임의 키치함을 위해 네온 핑크/옐로우 믹스
2. **Motion:** `SpringCurve`(`Curves.elasticOut`)로 쫀득한 인터랙션 구현
3. **UX:** 복잡한 튜토리얼 없이 직관적인 행동 유도성(Affordance) 디자인
4. **Typography:** `-0.5` letter spacing으로 토스 특유의 가독성 확보

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
- [x] TDS 스타일 UI/UX
- [x] 햅틱 피드백
- [ ] 이심전심 텔레파시 모드
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
