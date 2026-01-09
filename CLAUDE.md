# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter 기반 얼굴 인식 앱. Google ML Kit을 사용하여 얼굴을 감지하고, 등록된 얼굴과 비교하여 인증하는 기능을 제공.

## Build & Run Commands

```bash
# 의존성 설치
flutter pub get

# iOS 시뮬레이터 빌드
flutter build ios --simulator

# 실제 iOS 기기 실행 (release)
flutter run -d <device_id> --release

# 연결된 디바이스 목록
flutter devices

# 분석
flutter analyze

# iOS Pod 설치 (ios/ 디렉토리에서)
cd ios && pod install
```

## Architecture

### 화면 흐름
```
SplashScreen (main.dart)
    ↓ 얼굴 등록 여부 확인
AuthScreen (등록/인증 모드)
    ↓ 인증 성공
MainScreen
```

### 핵심 컴포넌트

**FaceService** (`lib/services/face_service.dart`)
- ML Kit FaceDetector를 사용한 얼굴 감지
- SharedPreferences에 얼굴 특징 데이터 저장
- 랜드마크 기반 얼굴 비교 (유사도 0.6 이상 시 매칭)
- 정적 메서드로 구성된 서비스 클래스

**AuthScreen** (`lib/screens/auth_screen.dart`)
- 전면 카메라 초기화 및 프리뷰
- `isRegistered` 파라미터로 등록/인증 모드 구분
- 사진 촬영 → 얼굴 감지 → 등록 또는 비교 흐름

### 얼굴 특징 추출 방식
- 바운딩 박스 비율 (aspectRatio)
- 눈 사이 거리 (정규화)
- 코-입 거리 (정규화)
- 6개 랜드마크 좌표 (상대적 위치)

## iOS 특이사항

- 카메라 권한 필요 (`NSCameraUsageDescription` in Info.plist)
- ML Kit은 iOS 12+ 지원
- 실제 기기에서만 전면 카메라 테스트 가능

## Key Dependencies

- `camera`: 카메라 제어
- `google_mlkit_face_detection`: 얼굴 감지
- `shared_preferences`: 로컬 데이터 저장
