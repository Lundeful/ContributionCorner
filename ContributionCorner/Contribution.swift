//
//  Contribution.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import Foundation

struct Contribution: Codable, Equatable {
    let date: Date
    let count: Int
    
    static func == (lhs: Contribution, rhs: Contribution) -> Bool {
        return lhs.date == rhs.date &&
        lhs.count == rhs.count
    }
}
