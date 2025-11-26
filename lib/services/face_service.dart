import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class FaceService {
  static const String _faceDataKey = 'registered_face_data';

  static final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.15,
    ),
  );

  // 파일에서 얼굴 감지 (이미지 회전 보정 포함)
  static Future<List<Face>> detectFacesFromFile(String imagePath) async {
    try {
      debugPrint('이미지 파일 처리 시작: $imagePath');

      // 이미지 파일 읽기
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('파일이 존재하지 않음');
        return [];
      }

      // InputImage 생성
      final inputImage = InputImage.fromFilePath(imagePath);

      debugPrint('ML Kit 얼굴 감지 시작...');
      final faces = await _faceDetector.processImage(inputImage);
      debugPrint('감지된 얼굴 수: ${faces.length}');

      for (var i = 0; i < faces.length; i++) {
        final face = faces[i];
        debugPrint('얼굴 $i: boundingBox=${face.boundingBox}, '
            'landmarks=${face.landmarks.length}, '
            'contours=${face.contours.length}');
      }

      return faces;
    } catch (e, stackTrace) {
      debugPrint('얼굴 감지 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');
      return [];
    }
  }

  // 얼굴이 등록되어 있는지 확인
  static Future<bool> isFaceRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_faceDataKey);
  }

  // 얼굴 특징 데이터 저장
  static Future<void> registerFace(Face face) async {
    final faceData = _extractFaceFeatures(face);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_faceDataKey, jsonEncode(faceData));
    debugPrint('얼굴 등록 완료');
  }

  // 등록된 얼굴 데이터 삭제
  static Future<void> clearRegisteredFace() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_faceDataKey);
  }

  // 얼굴 비교
  static Future<bool> compareFace(Face currentFace) async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_faceDataKey);

    if (storedData == null) return false;

    final registeredFeatures = Map<String, dynamic>.from(jsonDecode(storedData));
    final currentFeatures = _extractFaceFeatures(currentFace);

    final similarity = _calculateSimilarity(registeredFeatures, currentFeatures);
    debugPrint('유사도: $similarity');

    return similarity > 0.6;
  }

  // 얼굴 특징 추출
  static Map<String, dynamic> _extractFaceFeatures(Face face) {
    final features = <String, dynamic>{};

    final boundingBox = face.boundingBox;
    features['aspectRatio'] = boundingBox.width / boundingBox.height;

    features['headEulerAngleX'] = face.headEulerAngleX ?? 0.0;
    features['headEulerAngleY'] = face.headEulerAngleY ?? 0.0;
    features['headEulerAngleZ'] = face.headEulerAngleZ ?? 0.0;

    features['smilingProbability'] = face.smilingProbability ?? 0.0;
    features['leftEyeOpenProbability'] = face.leftEyeOpenProbability ?? 0.0;
    features['rightEyeOpenProbability'] = face.rightEyeOpenProbability ?? 0.0;

    final landmarks = <String, Map<String, double>>{};

    void addLandmark(FaceLandmarkType type, String name) {
      final landmark = face.landmarks[type];
      if (landmark != null) {
        landmarks[name] = {
          'x': (landmark.position.x - boundingBox.left) / boundingBox.width,
          'y': (landmark.position.y - boundingBox.top) / boundingBox.height,
        };
      }
    }

    addLandmark(FaceLandmarkType.leftEye, 'leftEye');
    addLandmark(FaceLandmarkType.rightEye, 'rightEye');
    addLandmark(FaceLandmarkType.noseBase, 'noseBase');
    addLandmark(FaceLandmarkType.leftMouth, 'leftMouth');
    addLandmark(FaceLandmarkType.rightMouth, 'rightMouth');
    addLandmark(FaceLandmarkType.bottomMouth, 'bottomMouth');

    features['landmarks'] = landmarks;

    if (landmarks.containsKey('leftEye') && landmarks.containsKey('rightEye')) {
      final leftEye = landmarks['leftEye']!;
      final rightEye = landmarks['rightEye']!;
      features['eyeDistance'] = _calculateDistance(
        leftEye['x']!, leftEye['y']!,
        rightEye['x']!, rightEye['y']!,
      );
    }

    if (landmarks.containsKey('noseBase') && landmarks.containsKey('bottomMouth')) {
      final nose = landmarks['noseBase']!;
      final mouth = landmarks['bottomMouth']!;
      features['noseMouthDistance'] = _calculateDistance(
        nose['x']!, nose['y']!,
        mouth['x']!, mouth['y']!,
      );
    }

    return features;
  }

  static double _calculateDistance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  static double _calculateSimilarity(
    Map<String, dynamic> registered,
    Map<String, dynamic> current,
  ) {
    double totalScore = 0.0;
    int featureCount = 0;

    if (registered['aspectRatio'] != null && current['aspectRatio'] != null) {
      final diff = ((registered['aspectRatio'] as num) - (current['aspectRatio'] as num)).abs();
      totalScore += max(0.0, 1.0 - diff * 3);
      featureCount++;
    }

    if (registered['eyeDistance'] != null && current['eyeDistance'] != null) {
      final diff = ((registered['eyeDistance'] as num) - (current['eyeDistance'] as num)).abs();
      totalScore += max(0.0, 1.0 - diff * 5);
      featureCount++;
    }

    if (registered['noseMouthDistance'] != null && current['noseMouthDistance'] != null) {
      final diff = ((registered['noseMouthDistance'] as num) - (current['noseMouthDistance'] as num)).abs();
      totalScore += max(0.0, 1.0 - diff * 5);
      featureCount++;
    }

    final regLandmarks = registered['landmarks'] as Map<String, dynamic>?;
    final curLandmarks = current['landmarks'] as Map<String, dynamic>?;

    if (regLandmarks != null && curLandmarks != null) {
      for (final key in regLandmarks.keys) {
        if (curLandmarks.containsKey(key)) {
          final regPoint = regLandmarks[key] as Map<String, dynamic>;
          final curPoint = curLandmarks[key] as Map<String, dynamic>;

          final distance = _calculateDistance(
            (regPoint['x'] as num).toDouble(),
            (regPoint['y'] as num).toDouble(),
            (curPoint['x'] as num).toDouble(),
            (curPoint['y'] as num).toDouble(),
          );

          totalScore += max(0.0, 1.0 - distance * 3);
          featureCount++;
        }
      }
    }

    return featureCount > 0 ? totalScore / featureCount : 0.0;
  }

  static void dispose() {
    _faceDetector.close();
  }
}
