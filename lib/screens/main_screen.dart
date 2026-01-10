import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/face_service.dart';
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
  late List<Mission> _missions;

  @override
  void initState() {
    super.initState();
    _missions = Mission.getDummyList(count: 5);
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

              // 직원 정보 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildUserCard(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 임무 목록 타이틀
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
                    const Text('임무 목록', style: AppTextStyles.heading3),
                    const Spacer(),
                    StatusBadge.info('${_missions.length}건'),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 임무 목록
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: _missions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildMissionCard(_missions[index]),
                    );
                  },
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

  Widget _buildUserCard() {
    return GradientCard(
      gradient: AppColors.primaryGradient,
      child: Row(
        children: [
          // 프로필 아바타
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.textPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      '인증된 직원',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.verified,
                      color: AppColors.accent,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '얼굴 인증 완료',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // 재등록 버튼
          IconButton(
            onPressed: () => _showResetDialog(context),
            icon: Icon(
              Icons.refresh,
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Mission mission) {
    return GradientCard(
      onTap: () => _showMissionDetail(mission),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 상태 + 제목
          Row(
            children: [
              _buildStatusBadge(mission.status),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  mission.title,
                  style: AppTextStyles.heading3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 설명
          Text(
            mission.description,
            style: AppTextStyles.bodySecondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),

          // 고객 정보
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                mission.clientName,
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  mission.address,
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // 미디어 썸네일
          if (mission.hasMedia) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mission.media.length,
                itemBuilder: (context, index) {
                  final media = mission.media[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < mission.media.length - 1
                          ? AppSpacing.sm
                          : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => _openMediaViewer(mission.media, index),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
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
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: const Icon(
                                  Icons.play_circle_outline,
                                  color: AppColors.textPrimary,
                                  size: 28,
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
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

  void _openMediaViewer(List<MediaItem> media, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaViewerScreen(
          media: media,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _showMissionDetail(Mission mission) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MissionDetailSheet(mission: mission),
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

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('얼굴 재등록', style: AppTextStyles.heading3),
        content: const Text(
          '기존 등록된 얼굴을 삭제하고 새로 등록하시겠습니까?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await FaceService.clearRegisteredFace();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(isRegistered: false),
                  ),
                );
              }
            },
            child: const Text('확인', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

/// 임무 상세 바텀시트
class _MissionDetailSheet extends StatelessWidget {
  final Mission mission;

  const _MissionDetailSheet({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
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

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 + 상태
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        mission.title,
                        style: AppTextStyles.heading2,
                      ),
                    ),
                    _buildStatusBadge(mission.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 설명
                Text(mission.description, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.lg),

                // 정보 카드들
                _buildInfoRow(Icons.person, '고객', mission.clientName),
                if (mission.clientPhone != null)
                  _buildInfoRow(Icons.phone, '연락처', mission.clientPhone!),
                _buildInfoRow(Icons.location_on, '주소', mission.address),
                _buildInfoRow(
                  Icons.calendar_today,
                  '생성일',
                  _formatDate(mission.createdAt),
                ),
                if (mission.notes != null)
                  _buildInfoRow(Icons.note, '메모', mission.notes!),

                const SizedBox(height: AppSpacing.lg),

                // 닫기 버튼
                GradientButton(
                  text: '닫기',
                  onPressed: () => Navigator.pop(context),
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
