//
//  ContentView.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import SwiftUI
import AxisContribution

struct ContentView: View {
    let githubParser = GithubParser()
    @State private var contributions: [Date] = []
    @State private var username: String = "lundeful"
    @State private var isLoading = true
    
    let startDate: Date = Date.getDateFromOneYearAgo(for: Calendar.current.date(byAdding: .day, value: +2, to: Date.now)!)!

    var body: some View {
        VStack {
            Text("Commitment Corner")
                .font(.title)
                .bold()
            if isLoading {
                ProgressView()
            } else {
                AxisContribution(constant: .init(), source: contributions)
            }
        }
        .task {
            await getContributions()
        }
    }

    func getContributions() async {
        isLoading = true
        await githubParser.getLastYearsContributionsAsDates(for: username) { result in
            switch result {
            case .success(let days):
                contributions = days
            case .failure(let error):
                print(error.localizedDescription)
            }
            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
