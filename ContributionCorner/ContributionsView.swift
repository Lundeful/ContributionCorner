//
//  ContributionsView.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import SwiftUI
import AxisContribution

struct ContributionsView: View {
    @AppStorage("username") private var username: String = ""
    @AppStorage("showContributionCount") private var showContributionsCount: Bool = true

    @State private var contributions: [Date] = []
    @State private var isLoading = true

    let githubParser = GithubParser()
    
    var usernameView: some View {
        HStack {
            Spacer()
            Text(username)
            Spacer()
        }
    }
    
    var refreshButton: some View {
        Button {
            Task {
                await getContributions()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .buttonStyle(.plain)
    }
    
    var settingsButton: some View {
        Button {
            if #available(macOS 13.0, *) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            else {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
            NSApp.activate(ignoringOtherApps: true)
        } label: {
            Image(systemName: "gear")
        }
        .buttonStyle(.plain)
    }
    
    var toolbar: some View {
        ZStack {
            usernameView
            HStack {
                Text(showContributionsCount ? "\(contributions.count) contributions" : "")
                Spacer()
                refreshButton
                settingsButton
            }
        }
    }

    var body: some View {
        VStack {
            toolbar
            if username.isEmpty {
                Spacer()
                HStack(alignment: .center) {
                    Spacer()
                    Text("Enter your GitHub username in settings to get started")
                    Spacer()
                }
                Spacer()
            } else if isLoading {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                Spacer()
            } else {
                AxisContribution(constant: .init(), source: contributions)
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
