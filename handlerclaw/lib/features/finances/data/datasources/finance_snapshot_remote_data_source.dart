import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/config/api_endpoint.dart';
import 'package:handlerclaw/core/networks/dio_client.dart';
import 'package:handlerclaw/features/finances/data/responses/account_snapshots_response.dart';
import 'package:handlerclaw/features/finances/data/dto/account_snapshot_dto.dart';
import 'package:handlerclaw/core/utils/logger.dart';

class FinanceSnapshotRemoteDataSource {
  final Dio _dio;

  FinanceSnapshotRemoteDataSource(this._dio);

  Future<AccountSnapshotsResponseDto> getSnapshots(String accountId) async {
    const endpoint = ApiEndpoint.financeAccountSnapshots;

    try {
      Logger.api("GET", endpoint);

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'account_id': accountId,
          'per_page': 100, // Fetch many for local diff calculation
        },
      );

      return AccountSnapshotsResponseDto.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'FinanceSnapshotRemoteDataSource.getSnapshots (DioException)',
      );
      if (e.response != null) {
        return AccountSnapshotsResponseDto.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'FinanceSnapshotRemoteDataSource.getSnapshots (Unexpected)',
      );
      rethrow;
    }
  }

  Future<AccountSnapshotDto> createSnapshot({
    required String accountId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    const endpoint = ApiEndpoint.financeAccountSnapshots;

    try {
      Logger.api("POST", endpoint);

      final response = await _dio.post(
        endpoint,
        data: {
          'account_id': accountId,
          'amount': amount,
          'date': date.toIso8601String(),
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );

      final data = response.data['data']['snapshot'];
      return AccountSnapshotDto.fromJson(data);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'FinanceSnapshotRemoteDataSource.createSnapshot (DioException)',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'FinanceSnapshotRemoteDataSource.createSnapshot (Unexpected)',
      );
      rethrow;
    }
  }

  Future<void> deleteSnapshot(String id) async {
    final endpoint = '${ApiEndpoint.financeAccountSnapshots}/$id';

    try {
      Logger.api("DELETE", endpoint);
      await _dio.delete(endpoint);
    } on DioException catch (e, stackTrace) {
      Logger.error("Api Error on endpoint $endpoint: ${e.message}");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'FinanceSnapshotRemoteDataSource.deleteSnapshot (DioException)',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error("Unexpected error on endpoint $endpoint: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'FinanceSnapshotRemoteDataSource.deleteSnapshot (Unexpected)',
      );
      rethrow;
    }
  }
}

final financeSnapshotRemoteDataSourceProvider =
    Provider<FinanceSnapshotRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return FinanceSnapshotRemoteDataSource(dio);
});
