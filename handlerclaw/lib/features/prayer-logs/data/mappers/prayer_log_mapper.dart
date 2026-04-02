import 'package:handlerclaw/features/prayer-logs/data/dto/prayer_log_dto.dart';
import 'package:handlerclaw/features/prayer-logs/data/responses/prayer_log_summary_response_dto.dart';
import 'package:handlerclaw/features/prayer-logs/domain/entities/prayer_log_entity.dart';
import 'package:handlerclaw/features/prayer-logs/domain/entities/prayer_log_summary_entity.dart';

class PrayerLogMapper {
  static PrayerLogEntity fromDto(PrayerLogDto dto) {
    return PrayerLogEntity(
      id: dto.id,
      userId: dto.userId,
      date: dto.date,
      prayer: dto.prayer,
      category: dto.category,
      performed: dto.performed,
      performedAt: dto.performedAt,
      isQadha: dto.isQadha,
      method: dto.method,
      place: dto.place,
      notes: dto.notes,
    );
  }

  static List<PrayerLogEntity> fromDtos(List<PrayerLogDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }

  static PrayerLogSummaryEntity fromSummaryDto(PrayerLogSummaryData data) {
    // Wajib: subuh, dzuhur, ashar, maghrib, isya
    // Sunnah: dhuha, tahajud, witir
    // Jumat depends on context, but let's count it separately or include as needed.
    final individual = <String, IndividualPerformanceEntity>{
      'SUBUH': IndividualPerformanceEntity(total: data.performances.subuh.count, percentage: data.performances.subuh.percentage),
      'DZUHUR': IndividualPerformanceEntity(total: data.performances.dzuhur.count, percentage: data.performances.dzuhur.percentage),
      'ASHAR': IndividualPerformanceEntity(total: data.performances.ashar.count, percentage: data.performances.ashar.percentage),
      'MAGHRIB': IndividualPerformanceEntity(total: data.performances.maghrib.count, percentage: data.performances.maghrib.percentage),
      'ISYA': IndividualPerformanceEntity(total: data.performances.isya.count, percentage: data.performances.isya.percentage),
      'JUMAT': IndividualPerformanceEntity(total: data.performances.jumat.count, percentage: data.performances.jumat.percentage),
      'DHUHA': IndividualPerformanceEntity(total: data.performances.dhuha.count, percentage: data.performances.dhuha.percentage),
      'TAHAJUD': IndividualPerformanceEntity(total: data.performances.tahajud.count, percentage: data.performances.tahajud.percentage),
      'WITIR': IndividualPerformanceEntity(total: data.performances.witir.count, percentage: data.performances.witir.percentage),
    };

    final totalWajib = data.performances.subuh.count + data.performances.dzuhur.count + 
                       data.performances.ashar.count + data.performances.maghrib.count + 
                       data.performances.isya.count + data.performances.jumat.count;
    final totalSunnah = data.performances.dhuha.count + data.performances.tahajud.count + 
                        data.performances.witir.count;

    final performance = PerformanceEntity(
      totalWajib: totalWajib,
      totalSunnah: totalSunnah,
      performedWajib: data.grandTotal.totalWajibPerformed,
      performedSunnah: data.grandTotal.totalSunnahPerformed,
      percentageWajib: totalWajib > 0 ? (data.grandTotal.totalWajibPerformed / totalWajib) * 100 : 0,
      percentageSunnah: totalSunnah > 0 ? (data.grandTotal.totalSunnahPerformed / totalSunnah) * 100 : 0,
      count: CountEntity(
        wajib: data.grandTotal.totalWajibPerformed, // Performed counts
        sunnah: data.grandTotal.totalSunnahPerformed,
        subuh: data.count.subuh,
        dzuhur: data.count.dzuhur,
        ashar: data.count.ashar,
        maghrib: data.count.maghrib,
        isya: data.count.isya,
        jumat: data.count.jumat,
        dhuha: data.count.dhuha,
        tahajud: data.count.tahajud,
        witir: data.count.witir,
      ),
      grandTotal: GrandTotalEntity(
        total: data.grandTotal.totalPerformed + data.grandTotal.totalQadha,
        performed: data.grandTotal.totalPerformed,
        qadha: data.grandTotal.totalQadha,
        percentage: 0,
      ),
      individual: individual,
    );

    final summaryMap = <String, SummaryItemEntity>{};
    for (var item in data.summary) {
      final byPrayer = <String, PrayerDetailEntity>{};
      item.byPrayer.forEach((key, detail) {
        byPrayer[key] = PrayerDetailEntity(
          performed: detail.performed,
          qadha: detail.qadha,
          jamaah: detail.jamaah,
        );
      });

      summaryMap[item.label] = SummaryItemEntity(
        label: item.label,
        totalWajibPerformed: item.totalWajibPerformed,
        totalSunnahPerformed: item.totalSunnahPerformed,
        totalPerformed: item.totalPerformed,
        totalQadha: item.totalQadha,
        byPrayer: byPrayer,
      );
    }

    return PrayerLogSummaryEntity(
      performance: performance,
      summary: summaryMap,
      summaryList: summaryMap.values.toList(),
    );
  }
}
