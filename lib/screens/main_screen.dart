import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_card.dart';
import '../widgets/gradient_button.dart';
import 'auth_screen.dart';
import 'media_viewer_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 현재 진행중인 임무 (단일)
  late Mission _currentMission;

  @override
  void initState() {
    super.initState();
    // 현재 진행중인 임무
    _currentMission = Mission(
      id: 'mission_1',
      title: '실종자 한유성 추적',
      description: '''의뢰인 미팅 결과 한유성의 실종은 한형님이 원인으로 추정.

한형님의 행적조사를 위해 탐문수사 진행.

한형님의 행적이 의뢰인인 성하윤을 쫒는다는 점을 확인함.

의뢰인 성하윤은 현재 연락 두절 상태로 마지막 미팅 장소인 의뢰인의 거주지 방문 예정.''',
      clientName: '성하윤',
      clientPhone: '연락두절',
      address: '기밀사항',
      status: MissionStatus.inProgress,
      createdAt: DateTime.now(),
      media: [
        MediaItem.asset(
          id: 'media_1',
          assetPath: 'assets/media/image_01.jpg',
          type: MediaType.image,
        ),
        MediaItem.asset(
          id: 'media_2',
          assetPath: 'assets/media/image_02.jpg',
          type: MediaType.image,
        ),
        MediaItem.asset(
          id: 'media_3',
          assetPath: 'assets/media/image_03.jpg',
          type: MediaType.image,
        ),
        MediaItem.asset(
          id: 'media_4',
          assetPath: 'assets/media/113244.mp4',
          type: MediaType.video,
        ),
      ],
    );
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
              _buildHeader(),

              // 현재 임무 타이틀
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('현재 임무', style: AppTextStyles.heading3),
                    const Spacer(),
                    _buildStatusBadge(_currentMission.status),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 현재 임무 카드 (확장)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _buildCurrentMissionCard(),
                ),
              ),

              // 하단 완료 버튼
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: GradientButton(
                  text: '완료',
                  icon: Icons.check,
                  onPressed: () => _showCompleteDialog(),
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // 로고
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.face,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '다해조',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '심부름센터',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),
          // 로그아웃 버튼
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(
              Icons.logout,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMissionCard() {
    return GradientCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              _currentMission.title,
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppSpacing.md),

            // 설명
            Text(
              _currentMission.description,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.lg),

            // 구분선
            Divider(color: AppColors.surfaceLight.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.md),

            // 의뢰인 정보
            _buildInfoRow(Icons.person, '의뢰인', _currentMission.clientName),
            if (_currentMission.clientPhone != null)
              _buildInfoRow(Icons.phone, '연락처', _currentMission.clientPhone!),
            _buildInfoRow(Icons.location_on, '주소', _currentMission.address),

            // 메모
            if (_currentMission.notes != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _currentMission.notes!,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 미디어 미리보기 (있는 경우)
            if (_currentMission.hasMedia) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Icon(
                    Icons.photo_library,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '첨부 파일 ${_currentMission.media.length}개',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _currentMission.media.length,
                  itemBuilder: (context, index) {
                    final media = _currentMission.media[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < _currentMission.media.length - 1
                            ? AppSpacing.sm
                            : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => _openMediaViewer(index),
                        child: _buildMediaThumbnail(media),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 60,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaThumbnail(MediaItem media) {
    // 이미지 프로바이더 결정
    ImageProvider? imageProvider;
    if (media.type == MediaType.image) {
      if (media.isAsset) {
        imageProvider = AssetImage(media.url);
      } else if (media.thumbnail != null) {
        imageProvider = NetworkImage(media.thumbnail!);
      }
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        image: imageProvider != null
            ? DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: media.type == MediaType.video
          ? Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.play_circle_outline,
                color: AppColors.textPrimary,
                size: 32,
              ),
            )
          : null,
    );
  }

  Widget _buildStatusBadge(MissionStatus status) {
    switch (status) {
      case MissionStatus.pending:
        return StatusBadge.warning(status.label);
      case MissionStatus.inProgress:
        return StatusBadge.info(status.label);
      case MissionStatus.completed:
        return StatusBadge.success(status.label);
      case MissionStatus.cancelled:
        return StatusBadge.danger(status.label);
    }
  }

  // 미디어 뷰어 열기
  void _openMediaViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaViewerScreen(
          media: _currentMission.media,
          initialIndex: index,
        ),
      ),
    );
  }

  // 임무 완료 다이얼로그
  void _showCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        icon: const Icon(
          Icons.warning_rounded,
          color: AppColors.danger,
          size: 48,
        ),
        title: const Text(
          '임무를 완료할 수 없습니다',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.danger,
          ),
        ),
        content: const Text(
          '현재 진행 중인 임무는 완료 처리할 수 없습니다.',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('로그아웃', style: AppTextStyles.heading3),
        content: const Text(
          '잠금 화면으로 돌아가시겠습니까?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(isRegistered: true),
                ),
              );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

}
