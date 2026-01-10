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
    // 더미 데이터: 현재 진행중인 임무 1개
    _currentMission = Mission.dummy(index: 1);
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

              // 하단 버튼 영역
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    // 임무기록 버튼
                    Expanded(
                      child: OutlineButton(
                        text: '임무기록',
                        icon: Icons.photo_library,
                        onPressed: () => _showMediaListSheet(),
                        isFullWidth: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // 완료 버튼
                    Expanded(
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

            // 고객 정보
            _buildInfoRow(Icons.person, '고객', _currentMission.clientName),
            if (_currentMission.clientPhone != null)
              _buildInfoRow(Icons.phone, '연락처', _currentMission.clientPhone!),
            _buildInfoRow(Icons.location_on, '주소', _currentMission.address),
            _buildInfoRow(
              Icons.calendar_today,
              '생성일',
              _formatDate(_currentMission.createdAt),
            ),

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
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        image: media.thumbnail != null
            ? DecorationImage(
                image: NetworkImage(media.thumbnail!),
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

  // 미디어 목록 바텀시트
  void _showMediaListSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MediaListSheet(
        media: _currentMission.media,
        onMediaTap: (index) {
          Navigator.pop(context);
          _openMediaViewer(index);
        },
      ),
    );
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
        title: const Text('임무 완료', style: AppTextStyles.heading3),
        content: const Text(
          '이 임무를 완료 처리하시겠습니까?',
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success),
                      SizedBox(width: AppSpacing.sm),
                      Text('임무가 완료 처리되었습니다'),
                    ],
                  ),
                  backgroundColor: AppColors.surface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              );
            },
            child: const Text('완료', style: TextStyle(color: AppColors.success)),
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

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

/// 미디어 목록 바텀시트
class _MediaListSheet extends StatelessWidget {
  final List<MediaItem> media;
  final Function(int) onMediaTap;

  const _MediaListSheet({
    required this.media,
    required this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text('임무 기록', style: AppTextStyles.heading3),
                const Spacer(),
                StatusBadge.info('${media.length}개'),
              ],
            ),
          ),

          // 미디어 그리드
          Flexible(
            child: media.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                    ),
                    itemCount: media.length,
                    itemBuilder: (context, index) {
                      return _buildMediaGridItem(media[index], index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '기록된 미디어가 없습니다',
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGridItem(MediaItem item, int index) {
    return GestureDetector(
      onTap: () => onMediaTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          image: item.thumbnail != null
              ? DecorationImage(
                  image: NetworkImage(item.thumbnail!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            // 비디오 아이콘
            if (item.type == MediaType.video)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    color: AppColors.textPrimary,
                    size: 36,
                  ),
                ),
              ),

            // 이미지 아이콘 (썸네일 없을 때)
            if (item.thumbnail == null && item.type == MediaType.image)
              const Center(
                child: Icon(
                  Icons.image,
                  color: AppColors.textMuted,
                  size: 36,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
