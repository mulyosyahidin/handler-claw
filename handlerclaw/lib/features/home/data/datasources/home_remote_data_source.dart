import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/features/home/data/responses/overview_response_dto.dart';
import 'package:handlerclaw/core/utils/logger.dart';

class HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSource(this._dio);

  Future<OverviewResponseDto> getOverview() async {
    const endpoint = ApiEndpoint.overview;

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(endpoint);

      return OverviewResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      if (e.response != null) {
        return OverviewResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      rethrow;
    }
  }
}

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return HomeRemoteDataSource(dio);
});
