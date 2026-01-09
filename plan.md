# 다해조 심부름센터 임무관리 앱

## 앱 목적
- **얼굴 인식 기반 직원 인증** → 임무 관리 시스템 접근
- web/play 프로젝트(다해조 채용 웹사이트)와 디자인 통일

## 주요 기능
1. **직원 인증**: 얼굴 인식으로 본인 확인
2. **현재 임무 확인**: 진행중인 임무 상세 정보 표시 (목록 아님)
3. **미디어 확인**: 임무 화면에서 사진/영상 클릭하여 재생

## 목표
Modern Blue 테마를 적용하여 전문적인 임무관리 앱 UI 구현

---

## 선택된 테마: Modern Blue

### 색상 팔레트
```
Primary:      #3B82F6 (밝은 파랑)
Primary Dark: #1E3A8A (진한 네이비)
Secondary:    #1E40AF (중간 파랑)
Accent:       #F59E0B (앰버/골드)
Success:      #10B981 (그린)
Danger:       #EF4444 (레드)
Background:   #0F172A (다크 네이비)
Surface:      #1E293B (다크 그레이)
Text:         #F8FAFC (화이트)
```

### 핵심 디자인 요소
- **카드**: gradient 배경 + border + shadow + hover lift
- **버튼**: gradient 배경, 둥근 모서리(20px+), 눌림 효과
- **간격**: xs(4), sm(8), md(16), lg(24), xl(32), 2xl(48)
- **애니메이션**: 0.3-0.4s 트랜지션, fade-in-up 효과
- **타이포그래피**: Noto Sans KR, 명확한 계층 구조

---

## 구현 계획

### 1단계: 테마 시스템 생성
**파일**: `lib/theme/app_theme.dart` (신규)

```dart
// 색상 팔레트 정의
// - Primary, Secondary, Accent, Success, Danger
// - Background, Surface, Text 색상
// - Light/Dark 테마 지원
```

### 2단계: 공통 위젯 생성
**파일**: `lib/widgets/` (신규 디렉토리)

| 위젯 | 설명 |
|------|------|
| `GradientCard` | gradient 배경 + shadow 카드 |
| `GradientButton` | gradient 버튼 + 애니메이션 |
| `StatusBadge` | 상태 표시 뱃지 |

### 3단계: 화면별 UI 개선

#### SplashScreen (`lib/main.dart`)
- gradient 배경 적용
- 로고/아이콘 애니메이션 추가
- 브랜드 타이포그래피 적용

#### AuthScreen (`lib/screens/auth_screen.dart`)
- 카드 스타일 카메라 프리뷰
- gradient 버튼 적용
- 상태 메시지 스타일링
- 진행 인디케이터 커스텀

#### MainScreen (`lib/screens/main_screen.dart`)
- 다해조 브랜딩 적용 (로고, 색상)
- 직원 정보 카드 (인증된 사용자)
- 임무 기록 목록 (리스트뷰)
- 각 임무별 사진/영상 썸네일 표시

#### MediaViewerScreen (`lib/screens/media_viewer_screen.dart`) - 신규
- 사진 전체화면 보기
- 영상 재생 (video_player)
- 스와이프로 이전/다음 미디어 탐색

---

## 수정 대상 파일

| 파일 | 작업 |
|------|------|
| `lib/theme/app_theme.dart` | 신규 생성 |
| `lib/widgets/gradient_card.dart` | 신규 생성 |
| `lib/widgets/gradient_button.dart` | 신규 생성 |
| `lib/main.dart` | 테마 적용, SplashScreen 개선 |
| `lib/screens/auth_screen.dart` | UI 컴포넌트 교체 |
| `lib/screens/main_screen.dart` | 임무 목록 UI로 전면 개편 |
| `lib/screens/media_viewer_screen.dart` | 신규 생성 (사진/영상 뷰어) |
| `lib/models/mission.dart` | 신규 생성 (임무 데이터 모델) |
| `pubspec.yaml` | video_player 의존성 추가 |

---

## 검증 방법

1. `flutter analyze` - 코드 분석 통과
2. iOS 시뮬레이터에서 각 화면 확인
3. 실제 기기에서 카메라 동작 테스트
4. 다크모드/라이트모드 전환 확인

---

## 예상 결과

- 다해조 브랜드 아이덴티티 통일
- 전문적인 임무관리 앱 느낌
- 다크 배경으로 얼굴 인증 강조
- 직원 신뢰감 및 사용성 향상
