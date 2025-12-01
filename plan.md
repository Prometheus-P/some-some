# Development Plan: 썸썸 (Thumb Some)

**Project:** 썸썸 - 하이퍼 캐주얼 소셜 인터랙티브 앱
**Version:** 1.0
**Last Updated:** 2025-12-01
**Current Phase:** MVP Complete → Phase 2 Planning

---

## Table of Contents
1. [Overview](#overview)
2. [Current Status](#current-status)
3. [Phase 1: MVP (Complete)](#phase-1-mvp-complete)
4. [Phase 2: Feature Expansion](#phase-2-feature-expansion)
5. [Phase 3: Platform & Scale](#phase-3-platform--scale)
6. [Technical Debt & Improvements](#technical-debt--improvements)
7. [Timeline](#timeline)
8. [Resource Requirements](#resource-requirements)

---

## Overview

### Project Goals
1. **MVP (Phase 1):** 쫀드기 챌린지 검증 - ✅ Complete
2. **Phase 2:** 추가 게임 모드 및 바이럴 기능 구현
3. **Phase 3:** 수익화, 커뮤니티, 해외 진출

### Success Metrics
- **Engagement:** 세션당 평균 3회+ 게임 플레이
- **Retention:** D7 40%+
- **Virality:** 친구 초대율 30%+
- **Quality:** 앱스토어 평점 4.5+, 크래시율 1% 미만

---

## Current Status

### ✅ Completed Features (MVP)
- [x] 쫀드기 챌린지 게임 로직
  - [x] 멀티터치 감지 (2인 동시 터치)
  - [x] Sin/Cos 기반 8자 이동 알고리즘
  - [x] 실시간 진행도 UI (0-100%)
  - [x] 충돌 감지 및 게임 종료 로직
- [x] Toss Design System 구현
  - [x] TDS 색상 팔레트 + 키치 핑크/옐로우
  - [x] Spring curve 애니메이션
  - [x] TossButton, FadeInUp 컴포넌트
- [x] 햅틱 피드백 시스템
  - [x] 게임 시작: Heavy Impact
  - [x] 진행 중: Light Impact (1초마다)
  - [x] 성공: Vibrate
  - [x] 실패: Heavy Impact x2
- [x] 결과 화면 (성공/실패)
- [x] CustomPainter 기반 60fps 렌더링

### 🚧 Known Issues
1. **초기 타겟 위치 하드코딩:** `targetA = Offset(100, 400)` → 화면 크기 기반으로 수정 필요
2. **작은 화면 미검증:** iPhone SE, Galaxy A 시리즈 테스트 필요
3. **Android 햅틱 권한:** `VIBRATE` 권한 체크 필요

### 📊 Current Metrics
- **Code Quality:** Single file (599 lines)
- **Performance:** 60fps+ (추정, 실기기 테스트 필요)
- **Test Coverage:** 0% (수동 테스트만 진행)

---

## Phase 1: MVP (Complete)

### Sprint 1: Core Game Logic ✅
**Duration:** 2 weeks
**Goal:** 기본 게임 플레이 가능

#### Tasks
- [x] Flutter 프로젝트 셋업
- [x] TDS 디자인 시스템 정의
- [x] IntroScreen UI 구현
- [x] GameScreen 기본 구조
- [x] 멀티터치 감지 로직
- [x] CustomPainter로 캐릭터 렌더링

### Sprint 2: Game Polish ✅
**Duration:** 1 week
**Goal:** 게임 느낌 완성

#### Tasks
- [x] Sin/Cos 기반 이동 알고리즘
- [x] 난이도 스케일링 (intensity)
- [x] 햅틱 피드백 추가
- [x] 결과 화면 (성공/실패)
- [x] FadeInUp 애니메이션

### Sprint 3: Testing & Bug Fix ✅
**Duration:** 3 days
**Goal:** 안정화

#### Tasks
- [x] 수동 테스트
- [x] 버그 수정
- [x] README 작성

---

## Phase 2: Feature Expansion

### Sprint 4: Refactoring & Architecture (2 weeks)

**Goal:** 확장 가능한 구조로 리팩토링

#### Tasks
1. **파일 분리**
   - [ ] `lib/core/design_system/tds.dart` 분리
   - [ ] `lib/shared/widgets/toss_button.dart` 분리
   - [ ] `lib/shared/widgets/fade_in_up.dart` 분리
   - [ ] `lib/features/intro/intro_screen.dart` 분리
   - [ ] `lib/features/sticky_fingers/` 모듈화
     - [ ] `sticky_fingers_screen.dart`
     - [ ] `game_painter.dart`
     - [ ] `game_logic.dart` (비즈니스 로직 분리)

2. **State Management 도입**
   - [ ] Riverpod 패키지 추가
   - [ ] `GameStateNotifier` 생성
   - [ ] UI와 로직 분리

3. **Technical Debt 해결**
   - [ ] 초기 타겟 위치 동적 계산
   - [ ] Android VIBRATE 권한 체크
   - [ ] 화면 크기별 레이아웃 대응

**Priority:** High
**Estimated Effort:** 40 hours

---

### Sprint 5: 이심전심 텔레파시 모드 (3 weeks)

**Goal:** 두 번째 게임 모드 추가

#### Tasks
1. **UI 구현**
   - [ ] `SoulSyncScreen` 생성
   - [ ] 화면 180도 회전 안내 화면
   - [ ] 상하 분할 레이아웃
   - [ ] O/X 버튼 컴포넌트
   - [ ] 진행도 표시 (1/20 ~ 20/20)

2. **게임 로직**
   - [ ] 질문 데이터 모델 정의
     ```dart
     class Question {
       String text;
       String optionA;  // O
       String optionB;  // X
     }
     ```
   - [ ] 초기 질문 리스트 20개 작성
   - [ ] 동시 선택 감지 로직
   - [ ] 궁합 점수 계산 알고리즘 (일치 개수 / 20 * 100)

3. **결과 화면**
   - [ ] 궁합 점수 UI (0-100%)
   - [ ] 점수별 멘트 (예: 90%+ "천생연분!", 50% "애매함", 30%- "물과 기름")
   - [ ] 재시작 버튼

4. **IntroScreen 수정**
   - [ ] "이심전심 텔레파시" 버튼 추가

**Priority:** High
**Estimated Effort:** 60 hours

**Question List Examples:**
```dart
final sampleQuestions = [
  Question(text: "이상형은?", optionA: "외모", optionB: "성격"),
  Question(text: "술 선호는?", optionA: "소주", optionB: "맥주"),
  Question(text: "반려동물?", optionA: "고양이", optionB: "강아지"),
  Question(text: "여행 스타일?", optionA: "계획형", optionB: "즉흥형"),
  Question(text: "영화 장르?", optionA: "액션", optionB: "로맨스"),
  // ... 15 more
];
```

---

### Sprint 6: Firebase 연동 (1 week)

**Goal:** 백엔드 기능 추가

#### Tasks
1. **Firebase Setup**
   - [ ] Firebase 프로젝트 생성
   - [ ] `firebase_core` 패키지 추가
   - [ ] iOS/Android 설정 파일 추가
   - [ ] 초기화 코드 작성

2. **Remote Config**
   - [ ] `firebase_remote_config` 패키지 추가
   - [ ] 질문 리스트 JSON 업로드
   - [ ] 앱에서 fetch & apply 로직
   - [ ] 캐싱 전략 (24시간)

3. **Analytics**
   - [ ] `firebase_analytics` 패키지 추가
   - [ ] 이벤트 정의 및 로깅
     - `game_start` (mode: sticky_fingers / soul_sync)
     - `game_complete` (success, duration)
     - `game_fail` (fail_time)
     - `share_result` (mode, score)

4. **Crashlytics**
   - [ ] `firebase_crashlytics` 패키지 추가
   - [ ] 에러 리포팅 설정

**Priority:** Medium
**Estimated Effort:** 20 hours

---

### Sprint 7: 결과 공유 기능 (2 weeks)

**Goal:** 바이럴 기능 추가

#### Tasks
1. **UI Design**
   - [ ] "영수증" 스타일 디자인 (토스 송금 느낌)
   - [ ] 필드: 두 사람 닉네임, 게임 모드, 결과, 날짜
   - [ ] 워터마크: "썸썸 앱에서 측정"

2. **Implementation**
   - [ ] 닉네임 입력 화면 (게임 전 or 후)
   - [ ] `screenshot` 패키지로 위젯 캡처
   - [ ] `share_plus` 패키지로 공유
   - [ ] 갤러리 저장 기능

3. **Template Examples**
   ```
   ┌─────────────────────────┐
   │      썸썸 영수증          │
   ├─────────────────────────┤
   │ 플레이어: 지민 💕 민수    │
   │ 게임: 쫀드기 챌린지       │
   │ 결과: 성공 (15초)        │
   │ 날짜: 2025.12.01        │
   ├─────────────────────────┤
   │  "천생연분!"             │
   │  썸썸 앱에서 측정         │
   └─────────────────────────┘
   ```

**Priority:** High (바이럴 핵심)
**Estimated Effort:** 40 hours

---

### Sprint 8: 복불복 룰렛 모드 (2 weeks)

**Goal:** 세 번째 게임 모드 추가

#### Tasks
1. **UI 구현**
   - [ ] `PenaltyRouletteScreen` 생성
   - [ ] 룰렛 원형 UI (CustomPainter)
   - [ ] 화살표/포인터 표시
   - [ ] 회전 애니메이션 (물리 기반 감속)

2. **게임 로직**
   - [ ] 벌칙 데이터 모델
     ```dart
     class Penalty {
       String id;
       String text;
       bool isCustom;  // 유저가 추가한 것인지
     }
     ```
   - [ ] 기본 프리셋 10개
     - "러브샷 하기"
     - "10초간 포옹"
     - "어깨 주물러주기"
     - "눈 보고 칭찬하기"
     - "손잡고 10분 걷기"
     - etc.
   - [ ] 랜덤 선택 알고리즘 (공정성 보장)
   - [ ] 회전 물리 시뮬레이션 (감속 커브)

3. **커스텀 벌칙 추가**
   - [ ] "벌칙 추가하기" 화면
   - [ ] 로컬 저장 (SharedPreferences)
   - [ ] 최대 20개 제한

4. **결과 화면**
   - [ ] 선택된 벌칙 전체 화면 표시
   - [ ] "다시 돌리기" 버튼

**Priority:** Medium
**Estimated Effort:** 40 hours

---

### Sprint 9: 레벨/난이도 시스템 (1 week)

**Goal:** 재플레이 동기 부여

#### Tasks
1. **레벨 디자인**
   - [ ] Lv 1 (탐색전): 10초, 느린 속도 (intensity 0.5x)
   - [ ] Lv 2 (접촉 사고): 15초, 중간 속도 (intensity 1.0x) ← 현재 기본
   - [ ] Lv 3 (밀착): 20초, 빠른 속도 (intensity 1.5x)
   - [ ] Lv 4 (화끈): 25초, 매우 빠름 (intensity 2.0x), 캐릭터 작아짐
   - [ ] Lv 5 (극한): 30초, 미친 속도 (intensity 3.0x), 장애물 추가

2. **UI 추가**
   - [ ] 레벨 선택 화면
   - [ ] 레벨별 설명 및 미리보기
   - [ ] 잠금 시스템 (이전 레벨 클리어해야 해금)

3. **배지 시스템**
   - [ ] 레벨별 성공 시 배지 부여
   - [ ] 배지 컬렉션 화면
   - [ ] 로컬 저장 (SharedPreferences)

**Priority:** Low
**Estimated Effort:** 20 hours

---

## Phase 3: Platform & Scale

### Sprint 10: Testing & QA (2 weeks)

**Goal:** 출시 준비

#### Tasks
1. **Unit Testing**
   - [ ] 게임 로직 테스트
     - [ ] 충돌 감지
     - [ ] 타이머
     - [ ] 점수 계산
   - [ ] 데이터 모델 테스트

2. **Widget Testing**
   - [ ] TossButton 테스트
   - [ ] FadeInUp 애니메이션 테스트
   - [ ] 결과 화면 UI 테스트

3. **Integration Testing**
   - [ ] 전체 게임 플로우 테스트
   - [ ] Firebase 연동 테스트

4. **Device Testing**
   - [ ] iOS: iPhone SE, 12, 14 Pro
   - [ ] Android: Galaxy S21, A52, Pixel 6
   - [ ] Tablet: iPad (optional)

5. **Performance Testing**
   - [ ] 60fps 유지 확인
   - [ ] 메모리 사용량 체크
   - [ ] 배터리 소모 측정

**Priority:** High
**Estimated Effort:** 60 hours

---

### Sprint 11: App Store Submission (1 week)

**Goal:** 앱스토어 등록

#### Tasks
1. **iOS Preparation**
   - [ ] App Icon (1024x1024)
   - [ ] Screenshots (5개)
   - [ ] Privacy Policy 작성
   - [ ] App Store Description (한국어)
   - [ ] TestFlight 베타 테스트 (50명)

2. **Android Preparation**
   - [ ] Feature Graphic (1024x500)
   - [ ] Screenshots (5개)
   - [ ] Play Store Description (한국어)
   - [ ] Closed Testing (50명)

3. **Legal & Compliance**
   - [ ] 이용약관 작성
   - [ ] 개인정보처리방침
   - [ ] 연령 등급 검토 (12세? 15세?)

**Priority:** High
**Estimated Effort:** 30 hours

---

### Sprint 12: Monetization (2 weeks)

**Goal:** 수익 모델 구현

#### Tasks
1. **In-App Purchase Setup**
   - [ ] `in_app_purchase` 패키지 추가
   - [ ] App Store Connect / Play Console 상품 등록
   - [ ] 구매 플로우 구현
   - [ ] 영수증 검증

2. **Product Design**
   - [ ] "화끈한 매운맛 팩" ($0.99)
     - Lv 4-5 해금
     - 특별 캐릭터 스킨 (🔥불곰, ⚡번개토끼)
     - 성인용 벌칙 프리셋 (선택적)
   - [ ] "프리미엄" ($2.99/month)
     - 광고 제거 (future)
     - 무제한 커스텀 벌칙
     - 독점 배지

3. **UI Integration**
   - [ ] 상점 화면
   - [ ] 구매 버튼
   - [ ] 복원 구매 기능

**Priority:** Medium
**Estimated Effort:** 40 hours

---

### Sprint 13: Marketing & Launch (Ongoing)

**Goal:** 유저 확보

#### Tasks
1. **Soft Launch**
   - [ ] 대학 커뮤니티 게시 (에브리타임 10개 학교)
   - [ ] 피드백 수집
   - [ ] 버그 핫픽스

2. **Content Creation**
   - [ ] 인스타그램 릴스 제작 (3개)
   - [ ] 유튜브 쇼츠 제작 (5개)
   - [ ] TikTok 챌린지 기획 (#썸썸챌린지)

3. **Influencer Outreach**
   - [ ] 커플 유튜버 협찬 (3팀)
   - [ ] 인스타그램 인플루언서 (10명)

4. **PR**
   - [ ] 보도자료 작성
   - [ ] 테크 미디어 피칭 (디스콰이엇, 긱뉴스)

**Priority:** High
**Estimated Effort:** Ongoing

---

## Technical Debt & Improvements

### Code Quality
- [ ] **Linting:** Enable all `flutter_lints` rules
- [ ] **Documentation:** Dartdoc comments for public APIs
- [ ] **Code Coverage:** 80%+ unit test coverage

### Performance
- [ ] **Profiling:** Xcode Instruments / Flutter DevTools 분석
- [ ] **Image Optimization:** 이미지 추가 시 WebP 사용
- [ ] **Build Size:** APK/IPA 크기 최적화 (목표: <10MB)

### Accessibility
- [ ] **Screen Reader:** Semantics widget 추가
- [ ] **Color Contrast:** WCAG AA 기준 충족
- [ ] **Font Scaling:** 시스템 폰트 크기 대응

### Internationalization
- [ ] `flutter_localizations` 패키지 추가
- [ ] 영어 번역 (Phase 3)
- [ ] 일본어 번역 (Phase 3)

---

## Timeline

### Q4 2025 (Current)
- ✅ Week 1-2: Sprint 1 (Core Game Logic)
- ✅ Week 3: Sprint 2 (Game Polish)
- ✅ Week 4: Sprint 3 (Testing & Bug Fix)
- 🔜 Week 5-6: Sprint 4 (Refactoring)

### Q1 2026
- Week 1-3: Sprint 5 (이심전심 텔레파시)
- Week 4: Sprint 6 (Firebase 연동)
- Week 5-6: Sprint 7 (결과 공유)
- Week 7-8: Sprint 8 (복불복 룰렛)
- Week 9: Sprint 9 (레벨 시스템)
- Week 10-11: Sprint 10 (Testing & QA)
- Week 12: Sprint 11 (App Store Submission)
- Week 13: Soft Launch

### Q2 2026
- Week 1-2: Sprint 12 (Monetization)
- Week 3-4: Public Launch + Marketing
- Week 5-8: 유저 피드백 반영 및 버그픽스
- Week 9-12: 커뮤니티 기능 기획 (랭킹, 챌린지)

### Q3 2026
- 영어 버전 출시
- 일본 시장 진출 검토
- 파트너십 (소개팅 앱)

---

## Resource Requirements

### Development Team
- **1x Flutter Developer (Full-time)**
  - 모든 코드 작성
  - 앱스토어 배포
  - 유지보수

- **1x Designer (Part-time, 주 2일)**
  - 게임 UI/UX
  - 마케팅 소재
  - 앱스토어 스크린샷

- **1x Marketer (Part-time, 주 3일)**
  - SNS 운영
  - 인플루언서 협찬
  - 데이터 분석

### Tools & Services
| Service | Purpose | Cost (월) |
|---------|---------|----------|
| Firebase (Spark Plan) | Analytics, Remote Config | $0 |
| Firebase (Blaze Plan) | Crashlytics (Phase 2) | ~$25 |
| Apple Developer | iOS 배포 | $99/year |
| Google Play Console | Android 배포 | $25 (일회성) |
| Figma | 디자인 | $0 (무료 플랜) |
| GitHub | 코드 관리 | $0 (Public repo) |
| **Total** | | **~$35/month** |

### Budget Estimate (Phase 2)
- **Development:** 280 hours × $50/hr = $14,000
- **Design:** 60 hours × $40/hr = $2,400
- **Marketing:** 100 hours × $30/hr = $3,000
- **Infrastructure:** $35/month × 3 months = $105
- **App Store Fees:** $124
- **Total:** **~$19,629**

---

## Risk Management

### High Priority Risks
1. **게임이 너무 어려워 유저 이탈**
   - **Mitigation:** 난이도 조절 가능하도록 설계, A/B 테스트
   - **Owner:** Developer

2. **햅틱이 기기별로 다르게 작동**
   - **Mitigation:** 다양한 기기 테스트, 옵션으로 on/off 제공
   - **Owner:** Developer

3. **선정성 논란으로 앱스토어 거부**
   - **Mitigation:** 콘텐츠 가이드라인 준수, 연령 등급 명확히
   - **Owner:** PM

### Medium Priority Risks
1. **경쟁 앱 등장**
   - **Mitigation:** 빠른 기능 추가, 브랜드 차별화
   - **Owner:** PM

2. **유행 단기 종료 (밈 수명)**
   - **Mitigation:** 지속적인 콘텐츠 업데이트, 커뮤니티 육성
   - **Owner:** Marketer

---

## Success Criteria (Phase 2)

### Launch Success (1 Month)
- [ ] 1,000 MAU
- [ ] 평균 세션 시간 5분+
- [ ] 크래시율 1% 미만
- [ ] 앱스토어 평점 4.5+

### Growth Success (3 Months)
- [ ] 10,000 MAU
- [ ] D7 Retention 40%+
- [ ] 유저 초대율 30%+
- [ ] 언론 보도 3건+

### Business Success (6 Months)
- [ ] 50,000 MAU
- [ ] ARPU $0.50+
- [ ] IAP 전환율 5%+
- [ ] Breakeven

---

## Next Actions (Immediate)

### This Week
1. [ ] Sprint 4 시작: `main.dart` 파일 분리
2. [ ] Riverpod 패키지 추가 및 학습
3. [ ] 초기 타겟 위치 버그 수정

### This Month
1. [ ] Sprint 4 완료 (리팩토링)
2. [ ] Sprint 5 시작 (이심전심 텔레파시)
3. [ ] 베타 테스터 50명 모집

### This Quarter
1. [ ] Sprint 5-9 완료 (모든 기능 구현)
2. [ ] Sprint 10 완료 (QA)
3. [ ] Soft Launch (에브리타임)

---

**Document Owner:** Development Team
**Last Review:** 2025-12-01
**Next Review:** 2026-01-01

---

## Appendix: Sprint Template

```markdown
### Sprint X: [Title] ([Duration])

**Goal:** [One-sentence goal]

#### Tasks
1. **[Category]**
   - [ ] Task 1
   - [ ] Task 2

**Priority:** [High/Medium/Low]
**Estimated Effort:** [Hours]
```

---

*"계획대로 되는 건 없지만, 계획 없이는 아무것도 안 된다."*
