//
//  ContributionsView.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import SwiftUI
import AxisContribution
import Combine

struct ContributionsView: View {
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("username") private var username: String = ""
    @AppStorage("showContributionCount") private var showContributionsCount: Bool = true
    @AppStorage("showUsername") private var showUsername: Bool = true
    @AppStorage("pollingRate") private var pollingRate: Double = 60

    @State private var contributions: [Date] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var showingSettings = false

    @State var timer: Timer.TimerPublisher = Timer.publish(every: 3, on: .main, in: .common)
    @State var connectedTimer: Cancellable? = nil

    private let githubParser = GithubParser()

    // Theming of contributions
    let darkBackgroundColor = Color(red: 23/255, green: 27/255, blue: 33/255)
    let lightBackgroundColor = Color(red: 240/255, green: 240/255, blue: 240/255)
    let foregroundColor = Color(red: 108/255, green: 209/255, blue: 100/255)
    let rowSize: CGFloat = 11

    var usernameView: some View {
        HStack {
            Spacer()
            if showUsername {
                Text(username)
                Link(destination: URL(string: "https://github.com/\(username)")!) {
                    Image(systemName: "link")
                }
                .focusable(false)
                .foregroundColor(.primary)
            }
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
        .focusable(false) // Removes focus ring, TODO: find alternative solution
    }

    var settingsButton: some View {
        Button {
            showingSettings.toggle()
        } label: {
            Image(systemName: "gear")
        }
        .buttonStyle(.plain)
        .focusable(false) // Removes focus ring, TODO: find alternative solution
    }

    var toolbar: some View {
        ZStack {
            usernameView
            HStack {
                Text(showContributionsCount ? "\(contributions.count) contribution\(contributions.count == 1 ? "" : "s")" : "")
                    .redacted(reason: isLoading ? .placeholder : [])
                Spacer()
                refreshButton
                settingsButton
            }
        }
    }

    var body: some View {
        VStack(alignment: .center) {
            toolbar
            if showingSettings {
                SettingsView(onDismiss: { showingSettings = false })
            }

            if username.isEmpty {
                Text("Enter your GitHub username in the settings to get started")
                    .frame(height: 150)
            } else if isLoading {
                ProgressView()
                    .frame(height: 150)
            }
            else {
                AxisContribution(constant: .init(), source: contributions) { indexSet, data in
                    RoundedRectangle(cornerRadius: 2)
                      .foregroundColor(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
                      .frame(width: rowSize, height: rowSize)
                } foreground: { indexSet, data in
                    if let data {
                        RoundedRectangle(cornerRadius: 2)
                            .foregroundColor(foregroundColor)
                            .frame(width: rowSize, height: rowSize)
                            .help("\(data.count.formatted()) contribution\(data.count == 1 ? "" : "s") on \(data.date.formatted(date: .abbreviated, time: .omitted))")
                    } else {
                        // This will be part of the less/more boxes beneath the graph
                        RoundedRectangle(cornerRadius: 2)
                            .foregroundColor(foregroundColor)
                            .frame(width: rowSize, height: rowSize)
                    }
                }
                .frame(height: 150)
            }
            if !errorMessage.isEmpty {
                HStack {
                    Spacer()
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Error occured while fetching contribution data")
                    Spacer()
                }
            }
        }
        .frame(width: 820)
        .padding()
        .task { await getContributions() }
        .onChange(of: username) { _ in Task { await getContributions() }}
        .onChange(of: pollingRate) { _ in restartTimer() }
        .onReceive(timer) { _ in
            Task { await getContributions() }
        }
    }

    func instantiateTimer() {
        self.timer = Timer.publish(every: max(60 * pollingRate, 60), on: .main, in: .common)
        self.connectedTimer = self.timer.connect()
        return
    }
    
    func cancelTimer() {
        self.connectedTimer?.cancel()
        return
    }

    func restartTimer() {
        self.cancelTimer()
        self.instantiateTimer()
        return
    }

    func getContributions() async {
        restartTimer()
        withAnimation {
            isLoading = true
        }

        await githubParser.getLastYearsContributionsAsDates(for: username) { result in
            switch result {
            case .success(let days):
                contributions = days
            case .failure(let error):
                contributions = []
                errorMessage = error.localizedDescription
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
