/// 임무 상태
enum MissionStatus {
  pending('대기중'),
  inProgress('진행중'),
  completed('완료'),
  cancelled('취소됨');

  final String label;
  const MissionStatus(this.label);
}

/// 미디어 타입
enum MediaType {
  image,
  video,
}

/// 미디어 아이템
class MediaItem {
  final String id;
  final String url;
  final MediaType type;
  final String? thumbnail;
  final DateTime createdAt;
  final bool isAsset; // 로컬 asset 여부

  const MediaItem({
    required this.id,
    required this.url,
    required this.type,
    this.thumbnail,
    required this.createdAt,
    this.isAsset = false,
  });

  // 로컬 asset 미디어 생성
  factory MediaItem.asset({
    required String id,
    required String assetPath,
    required MediaType type,
    String? thumbnailPath,
  }) {
    return MediaItem(
      id: id,
      url: assetPath,
      type: type,
      thumbnail: thumbnailPath,
      createdAt: DateTime.now(),
      isAsset: true,
    );
  }

  // 더미 데이터 생성
  factory MediaItem.dummy({
    required int index,
    MediaType type = MediaType.image,
  }) {
    return MediaItem(
      id: 'media_$index',
      url: type == MediaType.image
          ? 'https://picsum.photos/400/300?random=$index'
          : 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
      type: type,
      thumbnail: 'https://picsum.photos/200/150?random=$index',
      createdAt: DateTime.now().subtract(Duration(hours: index)),
    );
  }
}

/// 임무 모델
class Mission {
  final String id;
  final String title;
  final String description;
  final String clientName;
  final String? clientPhone;
  final String address;
  final MissionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<MediaItem> media;
  final String? notes;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.clientName,
    this.clientPhone,
    required this.address,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.media = const [],
    this.notes,
  });

  bool get hasMedia => media.isNotEmpty;
  int get imageCount => media.where((m) => m.type == MediaType.image).length;
  int get videoCount => media.where((m) => m.type == MediaType.video).length;

  // 더미 데이터 생성
  factory Mission.dummy({required int index}) {
    final statuses = MissionStatus.values;
    final status = statuses[index % statuses.length];

    return Mission(
      id: 'mission_$index',
      title: _dummyTitles[index % _dummyTitles.length],
      description: _dummyDescriptions[index % _dummyDescriptions.length],
      clientName: _dummyClients[index % _dummyClients.length],
      clientPhone: '010-1234-567$index',
      address: _dummyAddresses[index % _dummyAddresses.length],
      status: status,
      createdAt: DateTime.now().subtract(Duration(days: index)),
      completedAt: status == MissionStatus.completed
          ? DateTime.now().subtract(Duration(days: index - 1))
          : null,
      media: List.generate(
        (index % 4) + 1,
        (i) => MediaItem.dummy(
          index: index * 10 + i,
          type: i == 0 && index % 3 == 0 ? MediaType.video : MediaType.image,
        ),
      ),
      notes: index % 2 == 0 ? '특이사항: 배송 전 연락 필수' : null,
    );
  }

  static List<Mission> getDummyList({int count = 5}) {
    return List.generate(count, (i) => Mission.dummy(index: i));
  }
}

// 더미 데이터 목록
const _dummyTitles = [
  '서류 배달',
  '물품 픽업',
  '대기 업무',
  '긴급 배송',
  '현장 확인',
];

const _dummyDescriptions = [
  '고객 요청 서류를 지정 장소까지 배달합니다.',
  '지정 장소에서 물품을 수령하여 목적지로 전달합니다.',
  '고객 대신 지정 장소에서 대기 후 업무를 수행합니다.',
  '긴급 물품을 최대한 빠르게 목적지로 전달합니다.',
  '현장 상황을 확인하고 사진으로 기록합니다.',
];

const _dummyClients = [
  '김철수',
  '이영희',
  '박민수',
  '정수진',
  '최동욱',
];

const _dummyAddresses = [
  '서울시 강남구 테헤란로 123',
  '경기도 일산서구 주엽동 45-6',
  '서울시 마포구 홍대입구역 인근',
  '인천시 부평구 부평역 광장',
  '경기도 성남시 분당구 정자동',
];
