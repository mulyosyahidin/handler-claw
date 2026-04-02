import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/devices/domain/entities/user_device_entity.dart';
import 'package:handlerclaw/features/devices/domain/repositories/user_device_repository.dart';
import 'package:handlerclaw/features/devices/data/datasources/user_device_remote_data_source.dart';
import 'package:handlerclaw/features/devices/data/mappers/user_device_mapper.dart';

class UserDeviceRepositoryImpl implements UserDeviceRepository {
  final UserDeviceRemoteDataSource remoteDataSource;

  UserDeviceRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserDeviceListResult> getDevices({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    final response = await remoteDataSource.getDevices(
      page: page,
      perPage: perPage,
      search: search,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      return UserDeviceListResult(
        items: data.userDevices.map((dto) => UserDeviceMapper.fromDto(dto)).toList(),
        currentPage: data.meta.page,
        totalPages: data.meta.totalPages,
        totalItems: data.meta.total,
      );
    }

    return UserDeviceListResult(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    );
  }

  @override
  Future<UserDeviceEntity?> getDeviceDetail(String id) async {
    final response = await remoteDataSource.getDeviceDetail(id);
    
    if (response.success && response.data != null) {
      return UserDeviceMapper.fromDto(response.data!.userDevice);
    }
    
    return null;
  }
}

final userDeviceRepositoryProvider = Provider<UserDeviceRepository>((ref) {
  final remoteDataSource = ref.read(userDeviceRemoteDataSourceProvider);
  return UserDeviceRepositoryImpl(remoteDataSource);
});
