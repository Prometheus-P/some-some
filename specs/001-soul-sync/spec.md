# Feature Specification: 이심전심 텔레파시 (Soul Sync)

**Feature Branch**: `001-soul-sync`
**Created**: 2025-12-02
**Status**: Draft → **Revised**
**Input**: User description: "이심전심 텔레파시 (Soul Sync) mode"

## Clarifications

### Session 2025-12-02

- Q: 디자인 시스템 통합 전략 (TDS vs M3)? → A: Full M3 전환 - TDS를 Material Design 3로 완전 대체, Constitution 수정 필요
- Q: M3 색상 테마 접근 방식? → A: 커스텀 M3 테마 - kitschPink (#FF007F)를 seed color로 M3 tonal palette 생성
- Q: M3 모션 시스템 적용 범위? → A: 하이브리드 모션 - 일반 UI는 M3 easing (emphasized, standard), 게임 피드백(탭, 결과)은 elasticOut 유지
- Q: M3 컴포넌트 구현 방식? → A: 하이브리드 컴포넌트 - 일반 UI는 Flutter M3 위젯, 게임 UI (O/X 버튼, 결과 카드)는 커스텀 구현
- Q: 테마 모드 지원? → A: 다크 모드 전용 - M3 dark color scheme만 정의, 라이트 모드 미지원

## User Scenarios & Testing

### User Story 1 - 기본 궁합 테스트 플레이 (Priority: P1)

두 사람이 화면을 상하로 나눠 각자의 영역에서 같은 질문에 O/X로 답하고, 얼마나 답변이 일치하는지 확인하는 기본 게임 플로우.

**Why this priority**: 핵심 게임 메커닉. 이것 없이는 Soul Sync 모드가 존재할 수 없음.

**Independent Test**: 두 사람이 폰을 들고 5개 질문에 답한 후 일치율을 확인할 수 있음.

**Acceptance Scenarios**:

1. **Given** IntroScreen에서 Soul Sync 버튼을 탭, **When** 게임 화면 진입, **Then** 화면이 상하로 50:50 비율로 분할되어 각자의 영역이 180도 반전되어 표시됨
2. **Given** 게임 시작 상태, **When** 질문이 표시됨, **Then** 양쪽 모두 O/X 버튼이 표시되고 동일한 질문이 각자 방향에 맞게 보임 + 진행 상황 표시 (예: "1 / 5")
3. **Given** 한 사람이 답변 완료, **When** 다른 사람도 답변 완료, **Then** 다음 질문으로 자동 전환 (답변 결과는 아직 숨김)
4. **Given** 모든 질문(5개) 완료, **When** 결과 화면 표시, **Then** 일치한 답변 수와 궁합 퍼센트 표시 + 적절한 멘트

---

### User Story 2 - 결과 화면과 재시작 (Priority: P2)

게임 완료 후 결과를 보여주고, 다시 플레이하거나 홈으로 돌아갈 수 있는 플로우.

**Why this priority**: 게임 완료 후 필수 UX. P1 없이는 의미 없지만, P1만으로도 데모 가능.

**Independent Test**: 결과 화면에서 일치율 확인 후 "다시하기" 또는 "홈으로" 선택 가능.

**Acceptance Scenarios**:

1. **Given** 결과 화면, **When** 일치율 80% 이상 (4-5개 일치), **Then** "천생연분!" 멘트 + 🎉 이모지 + `HapticFeedback.vibrate()` + M3 primary 색상 강조
2. **Given** 결과 화면, **When** 일치율 50-79% (3개 일치), **Then** "꽤 맞네?" 멘트 + 😊 이모지 + `HapticFeedback.mediumImpact()` + M3 tertiary 색상
3. **Given** 결과 화면, **When** 일치율 50% 미만 (0-2개 일치), **Then** "이건 좀..." 멘트 + 😅 이모지 + `HapticFeedback.lightImpact()` + M3 onSurfaceVariant 색상 (긍정적 톤 유지)
4. **Given** 결과 화면, **When** "다시하기" 버튼 탭, **Then** 질문 풀에서 새로 셔플된 5개 질문으로 게임 재시작 (이전 세션 질문과 중복 가능)
5. **Given** 결과 화면, **When** "홈으로" 버튼 탭, **Then** IntroScreen으로 이동

---

### User Story 3 - 답변 대기 및 타이머 (Priority: P3)

한 사람이 답변했을 때 다른 사람을 기다리는 UI와 선택적 타이머 기능.

**Why this priority**: 게임 흐름을 부드럽게 하는 polish 기능. 없어도 P1/P2는 동작함.

**Independent Test**: 한 사람이 답변 후 대기 상태에서 자신의 영역에 "기다리는 중~" 표시 확인.

**Acceptance Scenarios**:

1. **Given** 질문 표시 상태, **When** 한 사람만 답변 완료, **Then** 그 사람 영역에 "기다리는 중~" 표시 + O/X 버튼 비활성화 (opacity 0.4), 상대 영역은 그대로
2. **Given** 대기 상태 10초(±0.5초) 경과, **When** 상대방 미응답, **Then** `HapticFeedback.lightImpact()`로 부드러운 힌트

---

### Edge Cases

- 한 사람이 계속 답변 안 하면? → MVP에서는 무한 대기, 10초마다 light haptic 힌트만 제공
- 게임 중 앱 백그라운드 이동? → 상태 유지 (StatefulWidget), 포그라운드 복귀 시 계속 진행
- 화면 회전? → 세로 모드 고정 (가로 모드 미지원), 시스템에서 회전 시도 시 무시
- 두 사람이 동시에 탭? → 둘 다 정상 처리, 먼저 도착한 이벤트부터 순차 처리 (Flutter 이벤트 큐 기본 동작)
- O/X 버튼 연속 빠른 탭? → 첫 번째 탭만 유효, 이후 탭은 무시 (버튼 즉시 비활성화)
- 게임 중 뒤로가기 제스처? → IntroScreen으로 복귀, 게임 상태 소멸 (별도 확인 없음, MVP)

## Requirements

### Functional Requirements

- **FR-001**: 화면이 상하로 50:50 비율로 분할, 상단 영역은 화면 중심점 기준으로 시계방향 180도 회전
- **FR-002**: 동일한 질문이 양쪽 영역에 각자 방향에 맞게 표시, 가운데에 진행 상황 "N / 5" 표시
- **FR-003**: O/X 버튼 탭 시 `HapticFeedback.mediumImpact()` 즉시 실행 (탭 이벤트 핸들러 첫 줄)
- **FR-004**: 양쪽 모두 답변 완료 시 자동으로 다음 질문 전환 (전환 애니메이션 없음, 즉시 교체)
- **FR-005**: 총 5개 질문 후 결과 화면 표시
- **FR-006**: 결과 화면에 일치 수 "N / 5 일치", 퍼센트 "NN%", 궁합 멘트, 이모지 표시
- **FR-007**: 질문 리스트는 하드코딩된 로컬 데이터 사용 (MVP), 총 10개 질문 풀에서 5개 랜덤 선택

### Layout Requirements

- **LR-001**: 분할 비율: 상단 50% / 하단 50% (Expanded 1:1)
- **LR-002**: O/X 버튼 크기: 80x80 논리 픽셀 (원형), 최소 터치 영역 충족
- **LR-003**: O/X 버튼 간격: 40 논리 픽셀
- **LR-004**: 질문 텍스트: M3 titleMedium (fontSize 18), 중앙 정렬
- **LR-005**: 영역 구분선: 높이 2px, M3 outlineVariant 색상

### Design System Requirements (M3 Migration)

- **DS-001**: Material Design 3 전면 적용 - TDS 완전 대체 (Constitution Principle III 수정 필요)
- **DS-002**: 색상 테마: kitschPink (#FF007F) seed color 기반 M3 tonal palette 생성
  - Primary: kitschPink 계열
  - Secondary/Tertiary: M3 알고리즘 자동 생성
  - Surface: M3 dark surface tokens
- **DS-003**: 모션 시스템 (하이브리드)
  - 일반 UI 전환: M3 easing (emphasizedDecelerate, standard)
  - 게임 피드백: Curves.elasticOut 유지 ("쫀득한" 느낌)
  - Duration tokens: M3 medium (300ms), short (150ms)
- **DS-004**: 컴포넌트 구현 (하이브리드)
  - 일반 UI: Flutter M3 위젯 (`FilledButton`, `Card`, `NavigationBar`)
  - 게임 UI: 커스텀 구현 (O/X 버튼, 결과 카드, PlayerArea)
- **DS-005**: 테마 모드: 다크 모드 전용 (`ColorScheme.fromSeed` with `Brightness.dark`)
- **DS-006**: Typography: M3 type scale 적용 (`TextTheme` from M3), 한글 최적화 폰트 유지

### Accessibility Requirements

- **AR-001**: O/X 버튼 터치 영역: 80x80 논리 픽셀 (iOS HIG 44pt 최소 기준 충족)
- **AR-002**: 질문 텍스트 색상 대비: M3 onSurface on M3 surface = WCAG AAA 충족 (M3 자동 보장)
- **AR-003**: O 버튼 색상 대비: M3 primary on M3 surface = WCAG AA 충족 (M3 자동 보장)
- **AR-004**: X 버튼 색상 대비: M3 tertiary on M3 surface = WCAG AA 충족 (M3 자동 보장)
- **AR-005**: 180도 회전된 영역에서도 텍스트 가독성 동일 (Transform.rotate로 전체 위젯 회전, 폰트 렌더링 영향 없음)
- **AR-006**: 스크린 리더 지원: MVP에서는 미지원 (향후 시맨틱 라벨 추가 예정)

### Key Entities

- **Question**: 질문 텍스트 (String), 인덱스 (0-9)
- **Answer**: 플레이어 ID ('A' 또는 'B'), 선택값 (bool: true=O, false=X)
- **GameSession**: 현재 질문 인덱스 (0-4), 현재 라운드 답변 Map, 완료된 답변 리스트, 완료 여부

## Success Criteria

### Measurable Outcomes

- **SC-001**: 두 사람이 5개 질문에 답하는 전체 플로우를 1분 이내에 완료 가능
  - 측정 시작점: Soul Sync 버튼 탭
  - 측정 종료점: 결과 화면 완전히 렌더링됨
  - 조건: 각 질문당 평균 10초 이하 응답 가정
- **SC-002**: 60fps 유지 (기존 쫀드기 챌린지와 동일한 퍼포먼스 기준)
  - 측정 도구: Flutter DevTools Performance 뷰
  - 기준: UI 스레드 평균 < 16ms, 프레임 드롭 0
  - 측정 구간: 게임 시작부터 결과 화면까지
- **SC-003**: 결과 화면 도달 후 "다시하기" 또는 "홈으로" 이동 가능
- **SC-004**: 기존 main.dart 파일 내에서 구현 (Constitution: Simplicity First)

### Testing Requirements

- **TR-001**: 햅틱 피드백 검증은 물리 기기에서만 가능 (시뮬레이터 불가)
- **TR-002**: 두 사람 대면 플레이 테스트 필수 (양쪽 동시 터치 검증)
- **TR-003**: iPhone SE (소형) ~ iPad (대형) 화면 크기 테스트 필요
