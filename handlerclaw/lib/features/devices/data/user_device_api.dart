import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/features/devices/data/response/user_device_list_response_dto.dart';
import 'package:handlerclaw/features/devices/data/response/user_device_detail_response_dto.dart';
import 'package:handlerclaw/shared/utils/logger.dart';

final userDeviceApiProvider = Provider<UserDeviceApi>((ref) {
  return UserDeviceApi(ref.read(dioProvider));
});

class UserDeviceApi {
  final Dio dio;

  UserDeviceApi(this.dio);

  Future<UserDeviceListResponseDto> getDevices({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    const endpoint = ApiEndpoint.userDevice;

    try {
      Logger.api("GET", endpoint);

      final response = await dio.get(
        endpoint,
        queryParameters: {
          "page": page,
          "per_page": perPage,
          if (search != null && search.isNotEmpty) "search": search,
        },
      );

      return UserDeviceListResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Error fetching devices: ${e.message}");
      rethrow;
    }
  }

  Future<UserDeviceDetailResponseDto> getDeviceDetail(String id) async {
    final endpoint = "${ApiEndpoint.userDevice}/$id";

    try {
      Logger.api("GET", endpoint);

      final response = await dio.get(endpoint);

      return UserDeviceDetailResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error("Error fetching device detail: ${e.message}");
      rethrow;
    }
  }
}
