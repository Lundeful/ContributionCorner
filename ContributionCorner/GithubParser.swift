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
}

class GithubParser {
    let baseUrl = "http://github.com/"

    func getLastYearsContributions(for user: String, completionHandler: @escaping (Result<[Contribution], NetworkError>) -> Void) async {
        guard let url = URL(string: baseUrl + user) else {
            print("Invalid URL")
            completionHandler(.failure(.badURL))
            return
        }

        do {
            let html = try String(contentsOf: url)
            let document = try SwiftSoup.parse(html)
            let contributions = try document.select("svg.js-calendar-graph-svg rect.ContributionCalendar-day")

            let mappedContributions = try contributions.map { day in
                let contributionCount = try Int(day.html().components(separatedBy: .whitespaces)[0]) ?? 0
                let date = try parseDate(date: day.attr("data-date"))!
                return Contribution(date: date, count: contributionCount)
            }

            let filteredContributions = mappedContributions.filter { $0.count > 0 }

            completionHandler(.success(filteredContributions))
        } catch {
            print("Error while parsing")
        }
    }
    
    func getLastYearsContributionsAsDates(for user: String, completionHandler: @escaping (Result<[Date], NetworkError>) -> Void) async {
        guard let url = URL(string: baseUrl + user) else {
            print("Invalid URL")
            completionHandler(.failure(.badURL))
            return
        }

        do {
            let html = try String(contentsOf: url)
            let document = try SwiftSoup.parse(html)
            let contributions = try document.select("svg.js-calendar-graph-svg rect.ContributionCalendar-day")

            let mappedContributions: [Date] = try contributions.flatMap { day in
                let contributionCount = try Int(day.html().components(separatedBy: .whitespaces)[0]) ?? 0
                if contributionCount == 0 { return [Date]() }

                let date = try parseDate(date: day.attr("data-date"))!
                return [Date](repeating: date, count: contributionCount)
            }

            completionHandler(.success(mappedContributions))
        } catch {
            print("Error while parsing")
        }
    }
    
    func parseDate(date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: date)
    }
}

