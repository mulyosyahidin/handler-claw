import WidgetKit
import SwiftUI

// MARK: - Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            subuh: false,
            dzuhur: false,
            ashar: false,
            maghrib: false,
            isya: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(getEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let timeline = Timeline(entries: [getEntry()], policy: .atEnd)
        completion(timeline)
    }

    private func getEntry() -> SimpleEntry {
        let ud = UserDefaults(suiteName: "group.com.martin.handlerclaw")
        return SimpleEntry(
            date: Date(),
            subuh:   ud?.bool(forKey: "subuh_done")   ?? false,
            dzuhur:  ud?.bool(forKey: "dzuhur_done")  ?? false,
            ashar:   ud?.bool(forKey: "ashar_done")   ?? false,
            maghrib: ud?.bool(forKey: "maghrib_done") ?? false,
            isya:    ud?.bool(forKey: "isya_done")    ?? false
        )
    }
}

// MARK: - Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let subuh, dzuhur, ashar, maghrib, isya: Bool
}

// MARK: - Widget View
struct PrayerWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    private let primaryRed   = Color(hex: "FF4D4D")
    private let successGreen = Color(hex: "4CAF50")
    private let bgWarm       = Color(hex: "FAF8F5")
    private let surfaceWhite = Color(hex: "FFFFFF")
    private let textPrimary  = Color(hex: "1A1814")
    private let textSecond   = Color(hex: "9A928A")
    private let borderColor  = Color(hex: "DDD7CE")

    private var prayers: [(name: String, done: Bool)] {
        [
            ("Subuh",   entry.subuh),
            ("Dzuhur",  entry.dzuhur),
            ("Ashar",   entry.ashar),
            ("Maghrib", entry.maghrib),
            ("Isya",    entry.isya)
        ]
    }

    private var doneCount: Int { prayers.filter(\.done).count }

    var body: some View {
        ZStack {
            bgWarm.ignoresSafeArea()
            if family == .systemMedium {
                mediumLayout
            } else {
                smallLayout
            }
        }
    }

    // MARK: Small
    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(primaryRed)
                Text("SHOLAT")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(primaryRed)
                    .tracking(1)
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(doneCount)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(textPrimary)
                Text("/ 5")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textSecond)
            }

            Spacer()

            HStack(spacing: 5) {
                ForEach(prayers, id: \.name) { prayer in
                    VStack(spacing: 3) {
                        Circle()
                            .fill(prayer.done ? successGreen : borderColor)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Group {
                                    if prayer.done {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 5, weight: .black))
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                        Text(prayer.name.prefix(3))
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(prayer.done ? textPrimary : textSecond)
                    }
                }
            }

            Text(entry.date, style: .time)
                .font(.system(size: 9))
                .foregroundColor(textSecond)
        }
        .padding(14)
    }

    // MARK: Medium
    private var mediumLayout: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(primaryRed)
                    Text("SHOLAT HARI INI")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(primaryRed)
                        .tracking(0.8)
                }

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(doneCount)")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(textPrimary)
                    Text("/ 5")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(textSecond)
                }

                Text(doneCount == 5 ? "Alhamdulillah! 🎉" : "\(5 - doneCount) lagi")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(doneCount == 5 ? successGreen : textSecond)

                Spacer()

                Text(entry.date, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(textSecond)
            }
            .padding(16)
            .frame(maxHeight: .infinity)

            Rectangle()
                .fill(borderColor)
                .frame(width: 1)
                .padding(.vertical, 12)

            VStack(spacing: 0) {
                ForEach(Array(prayers.enumerated()), id: \.element.name) { index, prayer in
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(prayer.done
                                      ? successGreen.opacity(0.15)
                                      : borderColor.opacity(0.4))
                                .frame(width: 26, height: 26)
                            Group {
                                if prayer.done {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(successGreen)
                                } else {
                                    Image(systemName: "circle")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(textSecond)
                                }
                            }
                        }

                        Text(prayer.name)
                            .font(.system(size: 13, weight: prayer.done ? .semibold : .regular))
                            .foregroundColor(prayer.done ? textPrimary : textSecond)

                        Spacer()

                        Group {
                            if prayer.done {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(successGreen)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)

                    if index < prayers.count - 1 {
                        Divider()
                            .padding(.horizontal, 14)
                            .opacity(0.5)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.vertical, 8)
        }
        .background(surfaceWhite)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(2)
    }
}

// MARK: - Color hex helper
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8)  & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Widget config
struct PrayerWidget: Widget {
    let kind = "PrayerWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Prayer Tracker")
        .description("Pantau status sholat hari ini.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}