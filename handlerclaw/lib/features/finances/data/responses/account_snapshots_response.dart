import 'package:handlerclaw/features/finances/data/dto/account_snapshot_dto.dart';

class AccountSnapshotsResponseDto {
  final bool success;
  final String message;
  final List<AccountSnapshotDto>? snapshots;

  AccountSnapshotsResponseDto({
    required this.success,
    required this.message,
    this.snapshots,
  });

  factory AccountSnapshotsResponseDto.fromJson(Map<String, dynamic> json) {
    return AccountSnapshotsResponseDto(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      snapshots: json['data'] != null && json['data']['snapshots'] != null
          ? (json['data']['snapshots'] as List)
              .map((e) => AccountSnapshotDto.fromJson(e))
              .toList()
          : null,
    );
  }
}
