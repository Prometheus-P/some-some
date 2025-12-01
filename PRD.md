# PRD: 썸썸 (Thumb Some)

**Product Requirements Document**
**Version:** 1.0
**Last Updated:** 2025-12-01
**Status:** MVP Complete, Planning Phase 2

---

## 1. Executive Summary

### 1.1 Product Vision
썸썸은 스킨십을 게임 메커니즘의 필수 요소로 만들어, 썸 단계 커플이나 소개팅 상황에서 자연스러운 신체 접촉을 유도하는 하이퍼 캐주얼 소셜 인터랙티브 앱입니다.

**핵심 가치 제안:**
> "게임인 척하며 자연스럽게 손잡기"

### 1.2 Problem Statement
- **Pain Point 1:** 썸 단계에서 스킨십 진도를 나가고 싶지만 명분이 없어 어색함
- **Pain Point 2:** 직접적인 스킨십 요청은 부담스럽고 민망함
- **Pain Point 3:** 술자리/카페에서 대화가 끊겼을 때 어색한 침묵

### 1.3 Solution
스마트폰 화면을 **함께 터치해야 하는** 게임으로 스킨십을 게임 규칙의 일부로 만들고, B급 감성과 웃음 코드로 민망함을 해소합니다.

### 1.4 Success Metrics (Phase 2 목표)
- **Primary KPI:** DAU 10,000+ (출시 3개월 후)
- **Engagement:** 세션당 평균 3회 이상 게임 플레이
- **Virality:** 친구 초대율 30%+
- **Retention:** D7 retention 40%+
- **Monetization:** ARPU $0.50 (IAP 전환율 5%)

---

## 2. Target Audience

### 2.1 Primary Persona: "썸타는 지민" (25세, 여성)
- **상황:** 3번째 만남인 남자와 카페 데이트 중
- **Pain Points:**
  - 대화 소재가 떨어지면 어색함
  - 상대방이 관심 있는지 확인하고 싶지만 직접 물어보긴 부담
  - 손 잡고 싶지만 먼저 잡기엔 오글거림
- **Goals:**
  - 자연스럽게 분위기 만들기
  - 상대방 반응 살피기
  - 재미있는 사람으로 보이기
- **썸썸 사용 시나리오:**
  - "내가 재미있는 앱 발견했는데 같이 해볼래?" (자연스러운 게임 제안)
  - 게임 중 손/팔이 닿으면서 스킨십 성공
  - 실패 시 벌칙으로 "10초 눈맞춤" → 로맨틱한 분위기 형성

### 2.2 Secondary Persona: "소개팅 준비하는 민수" (28세, 남성)
- **상황:** 친구 소개로 처음 만나는 여성과 저녁 식사 후
- **Pain Points:**
  - 첫 만남이라 어색함
  - 너무 적극적으로 나가면 부담스러워할까 걱정
  - 2차로 술집 가자고 하기엔 애매한 분위기
- **Goals:**
  - 아이스브레이킹
  - 상대방을 편하게 만들기
  - 다음 만남 약속 받아내기
- **썸썸 사용 시나리오:**
  - "친구가 만든 앱인데 테스트 좀 해달라는데 같이 해줄래?" (부담 없는 제안)
  - 게임 과정에서 자연스럽게 밀착
  - 성공 후 "우리 궁합 좋네~" 멘트로 다음 만남 암시

### 2.3 Tertiary Persona: "단체 술자리 분위기 메이커 수진" (23세, 여성)
- **상황:** 동아리/회사 MT, 새내기 환영회 등
- **Pain Points:**
  - 처음 보는 사람들과 빨리 친해져야 함
  - 술게임만 하기엔 지루함
- **Goals:**
  - 재미있는 게임 제공
  - 마음에 드는 이성과 접촉 기회 만들기
- **썸썸 사용 시나리오:**
  - "야 이거 완전 웃긴데 같이 해보자!" (그룹 활동)
  - 2인 1조로 진행, 실패 팀에게 벌칙
  - 자연스럽게 마음에 드는 이성과 팀 구성

---

## 3. Product Requirements

### 3.1 Functional Requirements (MVP - ✅ Complete)

#### FR-001: 쫀드기 챌린지 게임 로직
- **Description:** 두 사람이 각자 캐릭터(🐻곰, 🐰토끼)를 15초간 손가락으로 추적
- **Acceptance Criteria:**
  - [ ] 두 사람이 동시에 화면을 터치해야 게임 시작
  - [ ] 캐릭터가 화면을 Sin/Cos 조합으로 8자 경로 이동
  - [ ] 손가락을 떼거나 캐릭터를 놓치면 즉시 실패
  - [ ] 15초 버티면 성공 화면 표시
  - [ ] 진행도 UI (0% ~ 100%) 실시간 표시
- **Priority:** P0 (MVP Critical)
- **Status:** ✅ Implemented

#### FR-002: 햅틱 피드백 시스템
- **Description:** 게임 이벤트별 차별화된 진동 패턴 제공
- **Acceptance Criteria:**
  - [ ] 게임 시작: Heavy Impact
  - [ ] 1초마다 생존 시: Light Impact (심장 박동감)
  - [ ] 성공: Vibrate (축하)
  - [ ] 실패: Heavy Impact 2회 연속 (0.2초 간격)
- **Priority:** P0 (MVP Critical)
- **Status:** ✅ Implemented

#### FR-003: 결과 화면 (성공/실패)
- **Description:** 게임 종료 후 피드백 및 재시작 옵션
- **Acceptance Criteria:**
  - [ ] 성공 시: "천생연분!" 메시지 + 🎉 이모지 + 핑크 버튼
  - [ ] 실패 시: "띠로리~" 메시지 + 😱 이모지 + 벌칙 안내 + 빨간 버튼
  - [ ] "다시 도전" 버튼으로 재시작 가능
- **Priority:** P0 (MVP Critical)
- **Status:** ✅ Implemented

### 3.2 Functional Requirements (Phase 2 - Planned)

#### FR-101: 이심전심 텔레파시 모드
- **Description:** 화면 상하 분할, 질문에 O/X로 답하며 궁합 테스트
- **Acceptance Criteria:**
  - [ ] 화면이 180도 반전되어 상하 분할 (두 사람이 마주보고 진행)
  - [ ] 질문 리스트 20개 (예: "소주 vs 맥주?", "고양이 vs 강아지?")
  - [ ] 동시에 답 선택 → 같으면 💕, 다르면 ❌
  - [ ] 최종 궁합 점수 계산 (0~100%)
  - [ ] Firebase Remote Config로 질문 리스트 업데이트 가능
- **Priority:** P1 (Next Sprint)
- **Status:** ⏳ Not Started

#### FR-102: 복불복 룰렛 모드
- **Description:** 벌칙/미션 룰렛 (커스텀 입력 가능)
- **Acceptance Criteria:**
  - [ ] 기본 프리셋 10개 ("러브샷", "10초 포옹", "어깨 주물러주기" 등)
  - [ ] 사용자가 직접 벌칙 추가 가능 (최대 20개)
  - [ ] 룰렛 돌리는 애니메이션 (물리 기반 감속)
  - [ ] 선택된 벌칙 전체 화면 표시
- **Priority:** P2
- **Status:** ⏳ Not Started

#### FR-103: 결과 공유 기능
- **Description:** 게임 결과를 인스타 스토리 형식으로 공유
- **Acceptance Criteria:**
  - [ ] "영수증" 디자인 (토스 송금 느낌)
  - [ ] 닉네임 입력 (2인)
  - [ ] 공유하기 버튼 → 이미지로 저장 + SNS 공유
  - [ ] 워터마크: "썸썸 앱에서 측정"
- **Priority:** P1
- **Status:** ⏳ Not Started

#### FR-104: 레벨/난이도 시스템
- **Description:** 게임 난이도 선택 및 도전 과제
- **Acceptance Criteria:**
  - [ ] Lv 1 (탐색전): 느린 속도, 10초
  - [ ] Lv 2 (접촉 사고): 중간 속도, 15초
  - [ ] Lv 3 (밀착): 빠른 속도, 20초, 캐릭터 크기 축소
  - [ ] 레벨별 성공 시 배지 획득
- **Priority:** P2
- **Status:** ⏳ Not Started

### 3.3 Non-Functional Requirements

#### NFR-001: Performance
- **Requirement:** 60fps 이상 유지 (120fps 권장, ProMotion 지원)
- **Rationale:** 게임 느낌 결정하는 핵심 요소
- **Measurement:** Xcode Instruments / Flutter DevTools
- **Status:** ✅ Achieved (current implementation)

#### NFR-002: Accessibility
- **Requirement:** 최소 화면 크기 iPhone SE (4.7인치) 지원
- **Rationale:** 작은 화면도 두 사람이 터치 가능해야 함
- **Status:** ⚠️ Needs Testing

#### NFR-003: Localization
- **Requirement:** 한국어 전용 (v1.0)
- **Future:** 영어, 일본어 지원 (v2.0)
- **Status:** ✅ Korean Only

#### NFR-004: Compatibility
- **Requirement:** iOS 13+, Android 8.0+
- **Rationale:** 햅틱 API 지원 최소 버전
- **Status:** ✅ Set in pubspec.yaml

---

## 4. User Experience Requirements

### 4.1 UI/UX Principles

#### UX-001: No Tutorial Needed
- **Principle:** 직관적인 affordance로 설명 없이 플레이 가능
- **Implementation:**
  - "각자 캐릭터를 꾹 눌러주세요" 텍스트만 표시
  - 캐릭터에 빛나는 링 표시 (터치 유도)
  - 2명이 터치하면 자동으로 게임 시작

#### UX-002: Toss Design System
- **Colors:** TDS 베이스 + 키치 핑크/옐로우
- **Typography:** -0.5 letter spacing
- **Motion:** Spring curve (Curves.elasticOut)
- **Components:** Rounded corners (16px)

#### UX-003: B-Grade Sensibility
- **Tone:** 밈, 웃음 코드, 약간 오글거리는 멘트
- **Examples:**
  - "어머! 닿겠어!" (거리 가까울 때)
  - "이 정도면 사귀어야 하는 거 아님?" (성공 시)
  - "띠로리~" (실패 시)

### 4.2 User Flow

#### Primary Flow: 쫀드기 챌린지
```
1. 앱 실행 → IntroScreen
2. "쫀드기 챌린지 시작하기" 버튼 탭
3. GameScreen 진입
4. 두 사람이 각자 캐릭터 터치
5. 게임 자동 시작 (Heavy haptic)
6. 15초간 캐릭터 추적
   ├─ 성공 → "천생연분!" 화면 → "다음 단계로" (현재: 재시작)
   └─ 실패 → "띠로리~" 화면 + 벌칙 안내 → "다시 도전"
```

#### Secondary Flow: 이심전심 텔레파시 (Planned)
```
1. IntroScreen → "이심전심 텔레파시" 버튼 탭
2. 화면 회전 안내 (두 사람이 마주보기)
3. 질문 1/20 표시
4. O/X 동시 선택 → 결과 표시
5. 20문항 완료 → 궁합 점수 화면
6. 공유하기 or 다시하기
```

---

## 5. Technical Requirements

### 5.1 Tech Stack

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| Framework | Flutter 3.x | Single codebase iOS/Android, 60fps guarantee |
| Language | Dart 3.x | Type-safe, JIT/AOT compilation |
| State Mgmt | Riverpod (planned) | Provider보다 안전, 테스트 용이 |
| Graphics | CustomPainter | Direct canvas control for 60fps+ |
| Animation | Ticker + CustomPainter | Frame-by-frame control |
| Backend | Firebase (planned) | Remote Config, Analytics, Crashlytics |
| Payment | In-App Purchase (planned) | Revenue stream |

### 5.2 Architecture

**Current:** Single-file architecture (`main.dart`)
**Rationale:** Rapid prototyping, low overhead for MVP

**Future (Phase 2):**
```
lib/
├── main.dart
├── core/
│   ├── design_system/tds.dart
│   ├── utils/haptic_helper.dart
│   └── constants.dart
├── features/
│   ├── intro/
│   ├── sticky_fingers/
│   │   ├── sticky_fingers_screen.dart
│   │   ├── game_painter.dart
│   │   └── game_logic.dart
│   ├── soul_sync/
│   └── penalty_roulette/
└── shared/
    └── widgets/
        ├── toss_button.dart
        └── fade_in_up.dart
```

### 5.3 Data Model

#### Game State (Current)
```dart
class GameState {
  bool isPlaying;
  bool isGameOver;
  bool isSuccess;
  double progress;        // 0.0 ~ 1.0
  Map<int, Offset> pointers;
  Offset targetA;
  Offset targetB;
}
```

#### Analytics Events (Planned)
```dart
// Firebase Analytics
logEvent('game_start', {'mode': 'sticky_fingers'});
logEvent('game_complete', {'mode': 'sticky_fingers', 'success': true, 'duration': 15.2});
logEvent('game_fail', {'mode': 'sticky_fingers', 'fail_time': 8.3});
logEvent('share_result', {'mode': 'soul_sync', 'score': 85});
```

---

## 6. Monetization Strategy

### 6.1 Revenue Model (Phase 3)

#### Option A: In-App Purchase
- **화끈한 매운맛 팩** ($0.99)
  - 더 어려운 레벨 (Lv 4-5)
  - 특별한 캐릭터 스킨
  - 벌칙 프리셋 추가 (성인용)

#### Option B: Ads (Free Tier)
- **Interstitial Ad:** 게임 3회 실패 후 1회 표시
- **Rewarded Ad:** 광고 시청 시 벌칙 면제권

#### Option C: Premium ($2.99/month)
- 무제한 게임
- 광고 제거
- 모든 콘텐츠 팩 접근

### 6.2 A/B Testing Plan
- **Group A:** IAP only (50% users)
- **Group B:** Ads + IAP (50% users)
- **Metric:** 7-day ARPU, Retention

---

## 7. Go-to-Market Strategy

### 7.1 Launch Plan

#### Phase 1: Soft Launch (MVP)
- **Target:** 대학교 커뮤니티 (에브리타임, 대나무숲)
- **Tactic:** "개발자가 썸녀 꼬시려고 만든 앱ㅋㅋ" 바이럴
- **Goal:** 1,000 MAU, 피드백 수집

#### Phase 2: Public Release
- **Target:** 20-30대 일반인
- **Channels:**
  - 인스타그램 릴스 (유저 플레이 영상)
  - 유튜브 쇼츠 (커플 유튜버 협찬)
  - 틱톡 챌린지 (#썸썸챌린지)
- **Goal:** 10,000 MAU

#### Phase 3: Scale
- **Partnerships:** 소개팅 앱 (오늘의 소개팅, 아만다)
- **PR:** 언론 보도 ("MZ세대의 새로운 썸 타는 법")

### 7.2 Marketing Messages

| Channel | Message |
|---------|---------|
| Instagram | "썸 타는 너에게 필요한 앱 💕 게임 핑계로 손잡기 성공률 99%" |
| YouTube | "소개팅에서 이거 하면 무조건 2차 간다" |
| TikTok | "친구가 개발한 앱 테스트 해준다더니 손 잡고 있네?" |
| 커뮤니티 | "개발자인데 썸녀한테 '내가 만든 앱 테스트 해줘' 하니까 통함ㅋㅋ" |

---

## 8. Success Criteria

### 8.1 Launch Success (1 Month)
- [ ] 1,000 MAU
- [ ] 평균 세션 시간 5분+
- [ ] 크래시율 1% 미만
- [ ] 앱스토어 평점 4.5+

### 8.2 Growth Success (3 Months)
- [ ] 10,000 MAU
- [ ] D7 Retention 40%+
- [ ] 유저 초대율 30%+
- [ ] 언론 보도 3건+

### 8.3 Business Success (6 Months)
- [ ] 50,000 MAU
- [ ] ARPU $0.50+
- [ ] IAP 전환율 5%+
- [ ] Breakeven (손익분기점)

---

## 9. Risks & Mitigation

### 9.1 Product Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| 유저가 게임을 혼자 플레이 (의도 오해) | High | Medium | 튜토리얼 강화, "2인용" 명시 |
| 햅틱이 기기별로 다르게 작동 | Medium | High | 다양한 기기 테스트, 옵션 제공 |
| 게임이 너무 어려움 | High | Medium | 난이도 조절 옵션, A/B 테스트 |
| 선정성 논란 | High | Low | 콘텐츠 가이드라인 준수, 연령 제한 |

### 9.2 Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| 멀티터치 감지 오류 | High | Medium | 다양한 기기 테스트, fallback UI |
| 60fps 미달 (저사양 기기) | Medium | Medium | 그래픽 옵션 축소, 최소 사양 명시 |
| 배터리 소모 과다 | Low | Low | 백그라운드 일시정지, 최적화 |

### 9.3 Business Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| 경쟁 앱 등장 | Medium | High | 빠른 기능 추가, 브랜드 차별화 |
| 유행 단기 종료 (밈 수명) | High | Medium | 지속 콘텐츠 업데이트, 커뮤니티 육성 |
| 앱스토어 정책 위반 (선정성) | High | Low | 사전 검토, 연령 등급 준수 |

---

## 10. Roadmap

### Q4 2025
- [x] MVP 개발 (쫀드기 챌린지)
- [x] TDS 디자인 시스템 구현
- [ ] 베타 테스트 (대학생 50명)
- [ ] Soft Launch (에브리타임)

### Q1 2026
- [ ] 이심전심 텔레파시 모드
- [ ] 복불복 룰렛 모드
- [ ] Firebase 연동 (Analytics, Remote Config)
- [ ] 결과 공유 기능
- [ ] Public Release (iOS/Android)

### Q2 2026
- [ ] In-App Purchase 구현
- [ ] 레벨/난이도 시스템
- [ ] 소개팅 앱 파트너십
- [ ] 마케팅 캠페인 (유튜버 협찬)

### Q3 2026
- [ ] 커뮤니티 기능 (랭킹, 챌린지)
- [ ] 영어 버전 출시
- [ ] 일본 시장 진출 검토

---

## 11. Appendix

### 11.1 Competitive Analysis

| App | Similarity | Difference | Lesson |
|-----|-----------|-----------|---------|
| 밸런스 게임 앱 | 2인 상호작용 | 신체 접촉 없음 | UI 참고 |
| Kahoot | 실시간 퀴즈 | 그룹용, 교육 목적 | 게임화 요소 |
| Heads Up | 파티 게임 | 스킨십 유도 없음 | 바이럴 전략 |

### 11.2 User Research (Planned)
- [ ] 대학생 20명 인터뷰
- [ ] 소개팅 앱 유저 설문 (100명)
- [ ] 게임 플레이 세션 관찰 (10쌍)

### 11.3 References
- Toss 디자인 가이드
- Duolingo Gamification Study
- "Hooked" by Nir Eyal (습관 형성 메커니즘)

---

**Document Owner:** Product Team
**Reviewers:** Engineering, Design, Marketing
**Next Review:** 2026-01-01
