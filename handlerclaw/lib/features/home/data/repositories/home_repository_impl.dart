import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/home/data/datasources/home_remote_data_source.dart';
import 'package:handlerclaw/features/home/data/mappers/home_mapper.dart';
import 'package:handlerclaw/features/home/domain/entities/home_overview_entity.dart';
import 'package:handlerclaw/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<HomeOverviewEntity> getOverview() async {
    final response = await _remoteDataSource.getOverview();
    
    if (response.data == null) {
      throw Exception(response.message);
    }

    return HomeMapper.fromData(response.data!);
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.read(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource);
});
