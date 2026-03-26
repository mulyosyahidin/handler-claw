import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/shared/utils/logger.dart';
import 'package:handlerclaw/features/home/data/response/overview_response_dto.dart';

class HomeApi {
  final Dio dio;

  HomeApi(this.dio);

  Future<OverviewResponseDto> getOverview() async {
    const endpoint = ApiEndpoint.overview;

    try {
      Logger.api("GET", endpoint);

      final response = await dio.get(endpoint);

      return OverviewResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Api Error on endpoint $endpoint");

      if (e.response != null) {
        Logger.error("Status code: ${e.response?.statusCode}");
        Logger.error("Response body: ${e.response?.data}");
      } else {
        Logger.error("Network error: ${e.message}");
      }

      rethrow;
    } catch (e) {
      Logger.error("Unexpected error: $e");
      rethrow;
    }
  }
}

final homeApiProvider = Provider<HomeApi>((ref) {
  final dio = ref.read(dioProvider);

  return HomeApi(dio);
});
