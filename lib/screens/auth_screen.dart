import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/face_service.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isRegistered;

  const AuthScreen({super.key, required this.isRegistered});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _statusMessage = '';
  bool _isRegistrationMode = false;
  int _matchAttempts = 0;
  int _faceDetectedCount = 0;

  @override
  void initState() {
    super.initState();
    _isRegistrationMode = !widget.isRegistered;
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _statusMessage = '카메라를 찾을 수 없습니다.';
          });
        }
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high, // 해상도 높임
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _statusMessage = _isRegistrationMode
            ? '버튼을 눌러 얼굴을 등록하세요'
            : '버튼을 눌러 얼굴 인증하세요';
      });
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _statusMessage = '카메라 오류: $e';
        });
      }
    }
  }

  Future<void> _captureAndProcess() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = '처리 중...';
    });

    try {
      final image = await _cameraController!.takePicture();
      debugPrint('사진 촬영 완료: ${image.path}');

      // Apple Vision으로 얼굴 감지
      final faces = await FaceService.detectFacesFromFile(image.path);

      debugPrint('감지된 얼굴 수: ${faces.length}');

      if (faces.isEmpty) {
        setState(() {
          _statusMessage = '얼굴을 감지할 수 없습니다.\n밝은 곳에서 정면을 보고 다시 시도하세요.';
          _isProcessing = false;
        });
        return;
      }

      _faceDetectedCount++;
      final face = faces.first;
      debugPrint('얼굴 감지 성공! boundingBox: ${face.boundingBox}');

      if (_isRegistrationMode) {
        // 등록 모드
        await FaceService.registerFace(face);

        if (mounted) {
          setState(() {
            _statusMessage = '✓ 얼굴 등록 완료!';
          });

          await Future.delayed(const Duration(milliseconds: 1000));

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        }
      } else {
        // 인증 모드
        final isMatch = await FaceService.compareFace(face);
        debugPrint('얼굴 비교 결과: $isMatch');

        if (isMatch) {
          if (mounted) {
            setState(() {
              _statusMessage = '✓ 얼굴 인증 성공!';
            });

            await Future.delayed(const Duration(milliseconds: 1000));

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            }
          }
        } else {
          _matchAttempts++;
          if (mounted) {
            setState(() {
              _statusMessage = '얼굴이 일치하지 않습니다. ($_matchAttempts회 시도)';
              _isProcessing = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('처리 오류: $e');
      if (mounted) {
        setState(() {
          _statusMessage = '오류: $e';
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _resetFace() async {
    await FaceService.clearRegisteredFace();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthScreen(isRegistered: false),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 타이틀
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _isRegistrationMode ? '얼굴 등록' : '얼굴 인증',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 카메라 프리뷰
            Expanded(
              child: Center(
                child: _isInitialized && _cameraController != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: CameraPreview(_cameraController!),
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            '카메라 초기화 중...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ),

            // 상태 메시지
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            // 디버그 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '감지 횟수: $_faceDetectedCount | 시도: $_matchAttempts',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),

            // 캡처 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 10),
              child: ElevatedButton.icon(
                onPressed: _isProcessing || !_isInitialized ? null : _captureAndProcess,
                icon: Icon(_isRegistrationMode ? Icons.camera_alt : Icons.face),
                label: Text(_isRegistrationMode ? '얼굴 등록' : '얼굴 인증'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),

            // 재등록 버튼 (인증 실패 시)
            if (!_isRegistrationMode && _matchAttempts > 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextButton(
                  onPressed: _resetFace,
                  child: const Text(
                    '얼굴 다시 등록하기',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
