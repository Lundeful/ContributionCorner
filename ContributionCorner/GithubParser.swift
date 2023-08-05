//
//  GithubParser.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import Foundation
import SwiftSoup

enum NetworkError: Error {
    case badURL
    case parseError
}

struct GithubParser {
    static let baseUrl = "http://github.com/"

    static func getLastYearsContributionsAsDates(for user: String, completionHandler: @escaping (Result<[Date], NetworkError>) -> Void) async {
        guard let url = URL(string: baseUrl + user) else {
            print("Invalid URL")
            completionHandler(.failure(.badURL))
            return
        }

        do {
            let html = try String(contentsOf: url)
            let document = try SwiftSoup.parse(html)
            let contributions = try document.select("td.ContributionCalendar-day")

            let mappedContributions: [Date] = try contributions.flatMap { day in
                let spanContent = try day.select("span.sr-only").html()
                let contributionCount = Int(spanContent.split(separator: " ")[0]) ?? 0
                if contributionCount == 0 { return [Date]() }

                let date = try parseDate(date: day.attr("data-date"))!
                return [Date](repeating: date, count: contributionCount)
            }

            completionHandler(.success(mappedContributions))
        } catch {
            completionHandler(.failure(.parseError))
            print("Error while parsing")
        }
    }
    
    static func parseDate(date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: date)
    }
}

