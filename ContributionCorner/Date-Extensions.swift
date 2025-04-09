
import Foundation

extension Date {
    static func getDateFromOneYearAgo(for date: Date) -> Date? {
        return Calendar.current.date(byAdding: .year, value: -1, to: date)
    }

    static func getDatesInRange(from: Date, to: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = from
        while currentDate <= to {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }
}
