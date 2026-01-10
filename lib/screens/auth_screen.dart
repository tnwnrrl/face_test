import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/face_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_card.dart';
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
        ResolutionPreset.high,
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

  /// 관리자 암호 입력 다이얼로그
  void _showAdminPasswordDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppColors.accent),
            SizedBox(width: AppSpacing.sm),
            Text('관리자 인증', style: AppTextStyles.heading3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '얼굴 등록을 위해 관리자 암호를 입력하세요.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                letterSpacing: 8,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '••••',
                hintStyle: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                counterText: '',
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text == '8009') {
                Navigator.pop(context);
                _showAdminMenu();
              } else {
                Navigator.pop(context);
                _showAdminOnlyWarning();
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 관리자 메뉴 표시
  void _showAdminMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Row(
          children: [
            Icon(Icons.settings, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Text('관리자 설정', style: AppTextStyles.heading3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.face, color: AppColors.accent),
              title: const Text('얼굴 재등록', style: AppTextStyles.body),
              subtitle: const Text('새로운 얼굴로 등록합니다', style: AppTextStyles.caption),
              onTap: () {
                Navigator.pop(context);
                _enterRegistrationMode();
              },
            ),
            const Divider(color: AppColors.surfaceLight),
            ListTile(
              leading: const Icon(Icons.tune, color: AppColors.primary),
              title: const Text('인식 민감도', style: AppTextStyles.body),
              subtitle: const Text('얼굴 인식 임계값을 조절합니다', style: AppTextStyles.caption),
              onTap: () {
                Navigator.pop(context);
                _showThresholdDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  /// 임계값 설정 다이얼로그
  void _showThresholdDialog() async {
    double currentThreshold = await FaceService.getThreshold();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: const Row(
            children: [
              Icon(Icons.tune, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Text('인식 민감도', style: AppTextStyles.heading3),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '값이 높을수록 엄격하게 인식합니다.\n낮을수록 쉽게 통과합니다.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '${(currentThreshold * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Slider(
                value: currentThreshold,
                min: 0.3,
                max: 0.9,
                divisions: 12,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.surfaceLight,
                onChanged: (value) {
                  setDialogState(() {
                    currentThreshold = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('쉬움', style: AppTextStyles.caption),
                  Text('엄격', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                await FaceService.setThreshold(currentThreshold);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('민감도가 ${(currentThreshold * 100).toInt()}%로 설정되었습니다'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  /// 관리자 전용 경고 표시
  void _showAdminOnlyWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.accent),
            SizedBox(width: AppSpacing.sm),
            Text('관리자만 등록 가능합니다'),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 등록 모드로 전환
  void _enterRegistrationMode() async {
    await FaceService.clearRegisteredFace();
    if (!mounted) return;
    setState(() {
      _isRegistrationMode = true;
      _statusMessage = '버튼을 눌러 얼굴을 등록하세요';
      _matchAttempts = 0;
      _faceDetectedCount = 0;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 헤더
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        _isRegistrationMode ? Icons.person_add : Icons.lock,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRegistrationMode ? '얼굴 등록' : '얼굴 인증',
                            style: AppTextStyles.heading2,
                          ),
                          Text(
                            _isRegistrationMode
                                ? '새 얼굴을 등록합니다'
                                : '등록된 얼굴로 인증합니다',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    // 우상단 얼굴 등록 버튼
                    GestureDetector(
                      onTap: _showAdminPasswordDialog,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1,
                          color: AppColors.accent,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 카메라 프리뷰
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: GradientCard(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: _isInitialized && _cameraController != null
                          ? AspectRatio(
                              aspectRatio: 3 / 4,
                              child: CameraPreview(_cameraController!),
                            )
                          : Container(
                              color: AppColors.surface,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                    Text(
                                      '카메라 초기화 중...',
                                      style: AppTextStyles.bodySecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              // 상태 메시지
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // 상태 뱃지
                    if (_statusMessage.contains('✓'))
                      StatusBadge.success(_statusMessage.replaceAll('✓ ', ''))
                    else if (_statusMessage.contains('오류') ||
                        _statusMessage.contains('일치하지'))
                      StatusBadge.danger(_statusMessage.split('\n').first)
                    else if (_statusMessage.isNotEmpty)
                      StatusBadge.info(_statusMessage.split('\n').first),

                    if (_statusMessage.contains('\n')) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _statusMessage.split('\n').last,
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.sm),

                    // 디버그 정보
                    Text(
                      '감지: $_faceDetectedCount회 | 시도: $_matchAttempts회',
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ),

              // 버튼 영역
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    // 메인 버튼
                    GradientButton(
                      text: _isRegistrationMode ? '얼굴 등록' : '얼굴 인증',
                      icon: _isRegistrationMode ? Icons.camera_alt : Icons.face,
                      onPressed: _isProcessing || !_isInitialized
                          ? null
                          : _captureAndProcess,
                      isLoading: _isProcessing,
                      isFullWidth: true,
                    ),

                    // 재등록 버튼
                    if (!_isRegistrationMode && _matchAttempts > 2) ...[
                      const SizedBox(height: AppSpacing.md),
                      OutlineButton(
                        text: '얼굴 다시 등록하기',
                        icon: Icons.refresh,
                        color: AppColors.danger,
                        onPressed: _resetFace,
                        isFullWidth: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
