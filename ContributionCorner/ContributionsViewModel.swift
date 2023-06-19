//
//  ContributionsViewModel.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 19/06/2023.
//

import SwiftUI

@MainActor
final class ContributionsViewModel: ObservableObject {
    @AppStorage("username") var username = ""
    @Published var contributions: [Date] = []
    @Published var isInitialLoad = true
    @Published var isFetching = true
    @Published var errorMessage = ""

    init() {
        Task { await getContributions() }
    }

    func getContributions() async {
        guard !self.username.isEmpty else {
            self.contributions = []
            self.isFetching = false
            self.isInitialLoad = false
            return
        }

        await GithubParser.getLastYearsContributionsAsDates(for: self.username) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let days):
                    self.contributions = days
                    print("Successfully fetched contributions")
                case .failure(let error):
                    self.contributions = []
                    self.errorMessage = error.localizedDescription
                    print(error.localizedDescription)
                }

                self.isFetching = false
                self.isInitialLoad = false
            }
        }
    }
}
