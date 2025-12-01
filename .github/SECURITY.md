# Security Policy

## 🔒 보안 정책

썸썸(Thumb Some) 프로젝트의 보안을 중요하게 생각합니다. 보안 취약점을 발견하신 경우, 책임감 있는 공개(Responsible Disclosure) 원칙에 따라 리포트해주시기 바랍니다.

## 📋 지원되는 버전

현재 보안 업데이트를 받고 있는 버전:

| Version | Supported          | Status |
| ------- | ------------------ | ------ |
| 1.0.x   | :white_check_mark: | MVP - 개발 중 |
| < 1.0   | :x:                | 지원 안 함 |

**참고**: 현재 MVP 개발 단계로, 정식 릴리스 전입니다. Phase 2부터 프로덕션 보안 정책이 적용됩니다.

## 🚨 보안 취약점 리포트 방법

### 비공개 리포트 (권장)

보안 취약점은 **공개 이슈로 리포트하지 마세요**. 대신 다음 방법을 사용해주세요:

1. **GitHub Security Advisories** (권장)
   - [새로운 보안 권고 생성](https://github.com/Prometheus-P/some-some/security/advisories/new)
   - GitHub의 비공개 보안 리포팅 기능 사용
   - 취약점이 수정될 때까지 비공개로 유지됩니다

2. **이메일**
   - 보안팀 이메일: security@example.com
   - 제목: [SECURITY] 썸썸 보안 취약점 리포트
   - GPG 키로 암호화 권장 (공개키는 하단 참조)

### 리포트에 포함할 정보

명확한 리포트를 위해 다음 정보를 포함해주세요:

```markdown
## 취약점 요약
간단한 한 줄 설명

## 취약점 타입
- [ ] SQL Injection
- [ ] XSS (Cross-Site Scripting)
- [ ] CSRF (Cross-Site Request Forgery)
- [ ] Authentication Bypass
- [ ] Authorization Bypass
- [ ] Data Exposure
- [ ] Code Injection
- [ ] Path Traversal
- [ ] 기타: _____

## 영향도
- **심각도**: Critical / High / Medium / Low
- **영향 받는 컴포넌트**:
- **영향 받는 버전**:
- **공격 벡터**: Network / Adjacent / Local / Physical

## 재현 방법
1.
2.
3.

## 개념 증명 (PoC)
<!-- 가능하다면 PoC 코드나 스크린샷 첨부 -->

## 예상되는 영향
<!-- 이 취약점이 악용될 경우 어떤 일이 발생할 수 있는지 -->

## 제안하는 수정 방법
<!-- 알고 계신다면 제안해주세요 -->

## 추가 정보
<!-- 참고 자료, CVE 번호 등 -->
```

## ⏱️ 응답 시간

보안 취약점 리포트에 대한 응답 시간:

- **초기 응답**: 72시간 이내
- **심각도 평가**: 5일 이내
- **수정 계획 수립**: 7일 이내
- **패치 릴리스**: 심각도에 따라 다름
  - Critical: 7일 이내
  - High: 30일 이내
  - Medium: 60일 이내
  - Low: 90일 이내

## 🎯 보안 취약점 심각도 기준

CVSS 3.1 기준을 따릅니다:

### Critical (9.0-10.0)
- 인증 없이 원격으로 악용 가능
- 사용자 데이터 전체 노출
- 서비스 전체 장애 가능
- 즉시 대응 필요

### High (7.0-8.9)
- 특정 조건에서 원격 악용 가능
- 민감한 사용자 데이터 노출
- 주요 기능 장애
- 신속한 대응 필요

### Medium (4.0-6.9)
- 로컬 또는 제한적 조건에서 악용 가능
- 제한적인 데이터 노출
- 부분적 기능 장애
- 계획된 대응

### Low (0.1-3.9)
- 악용 조건이 매우 제한적
- 최소한의 영향
- 정기 업데이트에 포함

## 🛡️ 보안 모범 사례

### 개발자를 위한 가이드라인

#### 1. 코드 보안

```dart
// ❌ 나쁜 예: SQL Injection 취약
final query = "SELECT * FROM users WHERE id = $userId";

// ✅ 좋은 예: Prepared Statement 사용
final query = "SELECT * FROM users WHERE id = ?";
await db.query(query, [userId]);

// ❌ 나쁜 예: 사용자 입력 검증 없음
void updateProfile(String name) {
  // ...
}

// ✅ 좋은 예: 입력 검증
void updateProfile(String name) {
  if (name.isEmpty || name.length > 50) {
    throw ValidationException('Invalid name');
  }
  // ...
}
```

#### 2. 민감한 데이터 처리

```dart
// ❌ 나쁜 예: 평문으로 저장
await prefs.setString('password', password);

// ✅ 좋은 예: 암호화하여 저장 (Phase 2+)
await secureStorage.write(key: 'password', value: password);

// ❌ 나쁜 예: 로그에 민감한 정보 출력
print('User password: $password');

// ✅ 좋은 예: 로그에 민감한 정보 제외
print('User authenticated successfully');
```

#### 3. 네트워크 보안

```dart
// ❌ 나쁜 예: HTTP 사용
final url = 'http://api.example.com/data';

// ✅ 좋은 예: HTTPS 사용
final url = 'https://api.example.com/data';

// ✅ 좋은 예: Certificate Pinning (프로덕션)
final client = HttpClient()
  ..badCertificateCallback = (cert, host, port) => false;
```

#### 4. API 키 보호

```dart
// ❌ 나쁜 예: 코드에 하드코딩
const apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

// ✅ 좋은 예: 환경 변수 사용
final apiKey = const String.fromEnvironment('API_KEY');

// ✅ 더 좋은 예: Native 쪽에서 관리 (Phase 2+)
final apiKey = await platform.invokeMethod('getApiKey');
```

#### 5. 권한 체크

```dart
// ❌ 나쁜 예: 권한 체크 없이 실행
await readContacts();

// ✅ 좋은 예: 권한 확인 후 실행
if (await Permission.contacts.request().isGranted) {
  await readContacts();
} else {
  // 권한 거부 처리
}
```

### 의존성 관리

```yaml
# pubspec.yaml

# ❌ 나쁜 예: 버전 고정 없음
dependencies:
  http: any

# ✅ 좋은 예: 명확한 버전 범위
dependencies:
  http: ^1.1.0  # 1.1.0 이상 2.0.0 미만

# ✅ 더 좋은 예: 보안 업데이트 주기적 확인
# flutter pub outdated
# flutter pub upgrade --major-versions
```

## 🔍 보안 점검 체크리스트

### PR 리뷰 시 확인 사항

- [ ] **입력 검증**: 모든 사용자 입력이 검증되는가?
- [ ] **출력 인코딩**: XSS 방지를 위한 적절한 인코딩이 있는가?
- [ ] **인증/인가**: 적절한 권한 체크가 있는가?
- [ ] **민감 데이터**: 로그나 에러 메시지에 민감한 정보가 노출되지 않는가?
- [ ] **암호화**: 민감한 데이터가 암호화되어 저장되는가?
- [ ] **HTTPS**: 모든 네트워크 통신이 HTTPS를 사용하는가?
- [ ] **의존성**: 알려진 취약점이 있는 패키지를 사용하지 않는가?
- [ ] **하드코딩**: API 키나 시크릿이 코드에 하드코딩되지 않았는가?

### CI/CD 파이프라인

```yaml
# .github/workflows/ci.yml에 이미 포함된 보안 체크

- name: Dependency vulnerability check
  run: |
    flutter pub outdated
    # 알려진 취약점 체크 (Phase 2+)

- name: Secret scanning
  run: |
    # TruffleHog으로 시크릿 스캔
    docker run --rm -v "$PWD:/scan" trufflesecurity/trufflehog:latest \
      filesystem /scan --no-update
```

## 🏆 보안 공개 정책

### Hall of Fame

보안 취약점을 책임감 있게 공개해주신 분들:

<!--
| Researcher | Vulnerability | Severity | Date |
|------------|---------------|----------|------|
| @username  | XSS in ...    | Medium   | 2025-01 |
-->

*아직 리포트된 취약점이 없습니다. 첫 번째 기여자가 되어주세요!*

### 보상 정책

현재 MVP 단계로 공식적인 버그 바운티 프로그램은 없습니다. 하지만 다음과 같이 기여를 인정합니다:

- 🥇 **Critical/High 취약점**: Hall of Fame + GitHub Sponsors 후원
- 🥈 **Medium 취약점**: Hall of Fame + README 크레딧
- 🥉 **Low 취약점**: README 크레딧

Phase 2 이후 정식 버그 바운티 프로그램을 시작할 예정입니다.

## 📚 보안 관련 문서

- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [CONTRIBUTING.md](../CONTRIBUTING.md) - 보안 체크리스트 포함
- [CODE_REVIEW_GUIDE.md](../CODE_REVIEW_GUIDE.md) - 보안 리뷰 가이드라인

## 🔐 GPG 공개 키

보안 이메일 암호화용 GPG 공개 키:

```
-----BEGIN PGP PUBLIC KEY BLOCK-----
(Phase 2에 추가 예정)
-----END PGP PUBLIC KEY BLOCK-----
```

## 📧 연락처

- **보안팀 이메일**: security@example.com (설정 예정)
- **GitHub Security**: [Create Security Advisory](https://github.com/Prometheus-P/some-some/security/advisories/new)
- **일반 문의**: [GitHub Discussions](https://github.com/Prometheus-P/some-some/discussions)

## ⚖️ 법적 고지

- 이 프로젝트는 교육 및 연구 목적입니다
- 권한 없는 침투 테스트는 금지됩니다
- 책임감 있는 공개를 해주신 연구자는 법적 조치로부터 보호됩니다
- 악의적인 공격이나 데이터 유출은 법적 조치가 취해질 수 있습니다

---

**마지막 업데이트**: 2025-12-01
**버전**: 1.0.0
**담당자**: @Prometheus-P

보안은 모두의 책임입니다. 안전한 썸썸 앱을 만드는 데 도움을 주셔서 감사합니다! 🙏
