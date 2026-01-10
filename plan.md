# 다해조 심부름센터 임무관리 앱

## 앱 목적
- **얼굴 인식 기반 직원 인증** → 임무 관리 시스템 접근
- web/play 프로젝트(다해조 채용 웹사이트)와 디자인 통일

## 주요 기능
1. **직원 인증**: 얼굴 인식으로 본인 확인
2. **현재 임무 확인**: 진행중인 임무 상세 정보 표시 (목록 아님, 단일 임무)
3. **임무 기록**: 사진/영상 촬영 및 저장
4. **미디어 확인**: 저장된 사진/영상 팝업으로 확인

---

## 진행 상황

### ✅ 완료

| 항목 | 상태 |
|------|------|
| 테마 시스템 (`lib/theme/app_theme.dart`) | 완료 |
| 공통 위젯 (`GradientCard`, `GradientButton`, `StatusBadge`) | 완료 |
| SplashScreen UI 개선 | 완료 |
| AuthScreen UI 개선 + 관리자 등록 기능 | 완료 |
| iOS 전면 카메라 얼굴 감지 수정 (EXIF 방향 보정) | 완료 |
| 임시 파일 정리 로직 | 완료 |
| MediaViewerScreen 기본 구조 | 완료 |
| Mission 모델 | 완료 |
| MainScreen 개편 (단일 임무 표시) | 완료 |
| 임무기록 바텀시트 + MediaViewer 연동 | 완료 |
| 인증된 직원 카드 제거 | 완료 |
| 앱 이름 변경 (임무관리) | 완료 |
| 앱 아이콘 변경 (다해조 아이콘) | 완료 |

---

## 다음 작업

### 5단계: 정적 미디어 재생

#### 목표
- 사용자가 제공하는 이미지/영상 파일을 앱에 번들로 포함
- 임무기록 버튼 클릭 → 미디어 목록 표시 → 선택 시 재생

#### 구현 내용
- [ ] assets 폴더에 미디어 파일 추가
- [ ] pubspec.yaml에 assets 경로 등록
- [ ] Mission 모델에서 로컬 asset 경로 사용하도록 수정
- [ ] MediaViewerScreen에서 로컬 이미지/영상 재생 지원
- [ ] 영상 재생을 위한 video_player 패키지 연동

#### 파일 구조
```
assets/
└── media/
    ├── image_01.jpg
    ├── image_02.jpg
    └── video_01.mp4
```

#### 필요한 입력
- 이미지 파일들 (jpg, png)
- 영상 파일들 (mp4)

---

## 테마: Modern Blue

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

---

## 파일 구조

```
lib/
├── main.dart                    # 앱 진입점, SplashScreen
├── theme/
│   └── app_theme.dart           # 테마 시스템
├── models/
│   └── mission.dart             # 임무 데이터 모델
├── screens/
│   ├── auth_screen.dart         # 얼굴 인증 화면
│   ├── main_screen.dart         # 메인 화면 (현재 임무)
│   └── media_viewer_screen.dart # 미디어 뷰어
├── services/
│   └── face_service.dart        # 얼굴 인식 서비스
└── widgets/
    ├── gradient_card.dart       # 카드 위젯
    └── gradient_button.dart     # 버튼 위젯
```
