class PrayerLogSummaryEntity {
  final PerformanceEntity performance;
  final Map<String, SummaryItemEntity> summary;
  final List<SummaryItemEntity> summaryList;

  PrayerLogSummaryEntity({
    required this.performance,
    required this.summary,
    required this.summaryList,
  });
}

class PerformanceEntity {
  final int totalWajib;
  final int totalSunnah;
  final int performedWajib;
  final int performedSunnah;
  final double percentageWajib;
  final double percentageSunnah;
  final CountEntity count;
  final GrandTotalEntity grandTotal;
  final Map<String, IndividualPerformanceEntity> individual;

  PerformanceEntity({
    required this.totalWajib,
    required this.totalSunnah,
    required this.performedWajib,
    required this.performedSunnah,
    required this.percentageWajib,
    required this.percentageSunnah,
    required this.count,
    required this.grandTotal,
    required this.individual,
  });
}

class IndividualPerformanceEntity {
  final int total;
  final double? percentage;

  IndividualPerformanceEntity({
    required this.total,
    this.percentage,
  });
}

class CountEntity {
  final int wajib;
  final int sunnah;
  final int subuh;
  final int dzuhur;
  final int ashar;
  final int maghrib;
  final int isya;
  final int jumat;
  final int dhuha;
  final int tahajud;
  final int witir;

  CountEntity({
    required this.wajib,
    required this.sunnah,
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.jumat,
    required this.dhuha,
    required this.tahajud,
    required this.witir,
  });
}

class GrandTotalEntity {
  final int total;
  final int performed;
  final int qadha;
  final double percentage;

  GrandTotalEntity({
    required this.total,
    required this.performed,
    required this.qadha,
    required this.percentage,
  });
}

class SummaryItemEntity {
  final String label;
  final int totalWajibPerformed;
  final int totalSunnahPerformed;
  final int totalPerformed;
  final int totalQadha;
  final Map<String, PrayerDetailEntity> byPrayer;

  SummaryItemEntity({
    required this.label,
    required this.totalWajibPerformed,
    required this.totalSunnahPerformed,
    required this.totalPerformed,
    required this.totalQadha,
    required this.byPrayer,
  });
}

class PrayerDetailEntity {
  final int performed;
  final int qadha;
  final int jamaah;

  PrayerDetailEntity({
    required this.performed,
    required this.qadha,
    required this.jamaah,
  });
}
