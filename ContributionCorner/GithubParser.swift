import Foundation
import SwiftSoup

enum NetworkError: Error {
    case badURL
    case parseError
    case networkError(Error)
    case invalidResponse
}

struct GithubParser {
    static let baseUrl = "https://github.com/%@?action=show&controller=profiles&tab=contributions&user_id=%@"

    static func getLastYearsContributionsAsDates(for user: String, completionHandler: @escaping (Result<[Date], NetworkError>) -> Void) async {
        let urlString = String(format: baseUrl, user.lowercased(), user.lowercased())
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(.badURL))
            return
        }

        do {
            let html = try await fetchHTML(url: url)
            let document = try SwiftSoup.parse(html)

            let contributions = try document.select("td.ContributionCalendar-day")

            var mappedContributions: [Date] = []

            for day in contributions {
                do {
                    let dateString = try day.attr("data-date")
                    guard let date = parseDate(date: dateString) else { continue }

                    let dayId = try day.attr("id")
                    let tooltip = try document.select("tool-tip[for='\(dayId)']").first()
                    if let tooltipText = try tooltip?.text() {
                        let count = extractContributionCount(from: tooltipText)
                        if count > 0 {
                            mappedContributions += Array(repeating: date, count: count)
                        }
                    }
                } catch {
                    print("Debug: Error processing day: \(error)")
                }
            }

            completionHandler(.success(mappedContributions))

        } catch {
            completionHandler(.failure(.parseError))
        }
    }

    static func fetchHTML(url: URL) async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let html = String(data: data, encoding: .utf8) else {
            throw NetworkError.invalidResponse
        }

        return html
    }

    static func parseDate(date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: date)
    }

    static func extractContributionCount(from tooltipText: String) -> Int {
        if tooltipText.starts(with: "No contributions") {
            return 0
        }

        let components = tooltipText.components(separatedBy: " ")
        if let countString = components.first,
           let count = Int(countString) {
            return count
        }

        return 0
    }
}
