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
    @AppStorage("username") private var username: String = ""
    @AppStorage("showContributionCount") private var showContributionsCount: Bool = true
    @AppStorage("showUsername") private var showUsername: Bool = true
    @AppStorage("pollingRate") private var pollingRate: Double = 15

    @State private var contributions: [Date] = []
    @State private var isLoading = true
    @State private var errorMessage = ""

    private let githubParser = GithubParser()

    @State var timer: Timer.TimerPublisher = Timer.publish(every: 3, on: .main, in: .common)
    @State var connectedTimer: Cancellable? = nil

    var usernameView: some View {
        HStack {
            Spacer()
            Text(showUsername ? username : "")
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
        .focusable(false) // Removes focus ring, TODO: find alternative solution
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
                HStack(alignment: .center) {
                    ProgressView()
                }
                Spacer()
            } else {
                AxisContribution(constant: .init(), source: contributions)
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
        .frame(width: 820, height: 200)
        .padding()
        .onAppear(perform: instantiateTimer)
        .task {
            await getContributions()
        }
        .onChange(of: username) { _ in Task { await getContributions() }}
        .onChange(of: pollingRate) { _ in restartTimer() }
        .onReceive(timer) { _ in
            Task { await getContributions() }
        }
    }

    func instantiateTimer() {
        self.timer = Timer.publish(every: max(60 * pollingRate, 60 * 15), on: .main, in: .common)
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
