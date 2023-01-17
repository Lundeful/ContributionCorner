//
//  ContributionsView.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import SwiftUI
import AxisContribution

struct ContributionsView: View {
    let githubParser = GithubParser()
    @State private var contributions: [Date] = []
    @State private var username: String = "lundeful"
    @State private var isLoading = true
    
    let startDate: Date = Date.getDateFromOneYearAgo(for: Calendar.current.date(byAdding: .day, value: +2, to: Date.now)!)!

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                VStack(alignment: .leading ) {
                    HStack(alignment: .top) {
                        Text("\(contributions.count) contributions")
                        Spacer()
                        Button {
                            Task {
                                await getContributions()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }.buttonStyle(.plain)
                        Button {
                            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                        } label: {
                            Image(systemName: "gear")
                        }.buttonStyle(.plain)
                    }
                    AxisContribution(constant: .init(), source: contributions)
                }
            }
        }
        .frame(width: 820, height: 150)
        .padding()
        .task {
            await getContributions()
        }
    }

    func getContributions() async {
        withAnimation {
            isLoading = true
        }

        await githubParser.getLastYearsContributionsAsDates(for: username) { result in
            switch result {
            case .success(let days):
                contributions = days
            case .failure(let error):
                print(error.localizedDescription)
            }
            withAnimation {
                isLoading = false
            }
        }
    }
}

struct ContributionsView_Previews: PreviewProvider {
    static var previews: some View {
        ContributionsView()
    }
}
