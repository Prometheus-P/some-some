# Feature Specification: 이심전심 텔레파시 (Soul Sync)

**Feature Branch**: `001-soul-sync`
**Created**: 2025-12-02
**Status**: Draft
**Input**: User description: "이심전심 텔레파시 (Soul Sync) mode"

## User Scenarios & Testing

### User Story 1 - 기본 궁합 테스트 플레이 (Priority: P1)

두 사람이 화면을 상하로 나눠 각자의 영역에서 같은 질문에 O/X로 답하고, 얼마나 답변이 일치하는지 확인하는 기본 게임 플로우.

**Why this priority**: 핵심 게임 메커닉. 이것 없이는 Soul Sync 모드가 존재할 수 없음.

**Independent Test**: 두 사람이 폰을 들고 5개 질문에 답한 후 일치율을 확인할 수 있음.

**Acceptance Scenarios**:

1. **Given** IntroScreen에서 Soul Sync 버튼을 탭, **When** 게임 화면 진입, **Then** 화면이 상하로 분할되어 각자의 영역이 180도 반전되어 표시됨
2. **Given** 게임 시작 상태, **When** 질문이 표시됨, **Then** 양쪽 모두 O/X 버튼이 표시되고 동일한 질문이 각자 방향에 맞게 보임
3. **Given** 한 사람이 답변 완료, **When** 다른 사람도 답변 완료, **Then** 다음 질문으로 자동 전환 (답변 결과는 아직 숨김)
4. **Given** 모든 질문(5개) 완료, **When** 결과 화면 표시, **Then** 일치한 답변 수와 궁합 퍼센트 표시 + 적절한 멘트

---

### User Story 2 - 결과 화면과 재시작 (Priority: P2)

게임 완료 후 결과를 보여주고, 다시 플레이하거나 홈으로 돌아갈 수 있는 플로우.

**Why this priority**: 게임 완료 후 필수 UX. P1 없이는 의미 없지만, P1만으로도 데모 가능.

**Independent Test**: 결과 화면에서 일치율 확인 후 "다시하기" 또는 "홈으로" 선택 가능.

**Acceptance Scenarios**:

1. **Given** 결과 화면, **When** 일치율 80% 이상, **Then** "천생연분!" 멘트 + 축하 햅틱 + 화려한 이펙트
2. **Given** 결과 화면, **When** 일치율 50-79%, **Then** "꽤 맞네?" 멘트 + 보통 이펙트
3. **Given** 결과 화면, **When** 일치율 50% 미만, **Then** "이건 좀..." 멘트 + 아쉬운 이펙트 (but 긍정적 톤 유지)
4. **Given** 결과 화면, **When** "다시하기" 버튼 탭, **Then** 새로운 질문 세트로 게임 재시작
5. **Given** 결과 화면, **When** "홈으로" 버튼 탭, **Then** IntroScreen으로 이동

---

### User Story 3 - 답변 대기 및 타이머 (Priority: P3)

한 사람이 답변했을 때 다른 사람을 기다리는 UI와 선택적 타이머 기능.

**Why this priority**: 게임 흐름을 부드럽게 하는 polish 기능. 없어도 P1/P2는 동작함.

**Independent Test**: 한 사람이 답변 후 대기 상태에서 상대방 영역에 "대기 중..." 표시 확인.

**Acceptance Scenarios**:

1. **Given** 질문 표시 상태, **When** 한 사람만 답변 완료, **Then** 그 사람 영역에 "기다리는 중~" 표시, 상대 영역은 그대로
2. **Given** 대기 상태 10초 경과, **When** 상대방 미응답, **Then** 부드러운 진동으로 "빨리 골라!" 힌트

---

### Edge Cases

- 한 사람이 계속 답변 안 하면? → P3에서 타이머로 처리, MVP에서는 무한 대기
- 게임 중 앱 백그라운드 이동? → 상태 유지, 포그라운드 복귀 시 계속 진행
- 화면 회전? → 세로 모드 고정 (가로 모드 미지원)

## Requirements

### Functional Requirements

- **FR-001**: 화면이 상하로 분할되어 각 영역이 180도 회전되어 표시되어야 함
- **FR-002**: 동일한 질문이 양쪽 영역에 각자 방향에 맞게 표시되어야 함
- **FR-003**: O/X 버튼 탭 시 즉각적인 햅틱 피드백 제공
- **FR-004**: 양쪽 모두 답변 완료 시 자동으로 다음 질문 전환
- **FR-005**: 총 5개 질문 후 결과 화면 표시
- **FR-006**: 결과 화면에 일치 수, 퍼센트, 궁합 멘트 표시
- **FR-007**: 질문 리스트는 하드코딩된 로컬 데이터 사용 (MVP)

### Key Entities

- **Question**: 질문 텍스트, ID
- **Answer**: 질문 ID, 플레이어 (A/B), 선택값 (O/X)
- **GameSession**: 현재 질문 인덱스, 양쪽 답변 상태, 최종 결과

## Success Criteria

### Measurable Outcomes

- **SC-001**: 두 사람이 5개 질문에 답하는 전체 플로우를 1분 이내에 완료 가능
- **SC-002**: 60fps 유지 (기존 쫀드기 챌린지와 동일한 퍼포먼스 기준)
- **SC-003**: 결과 화면 도달 후 "다시하기" 또는 "홈으로" 이동 가능
- **SC-004**: 기존 main.dart 파일 내에서 구현 (Constitution: Simplicity First)
