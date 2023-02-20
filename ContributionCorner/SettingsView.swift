//
//  SettingsView.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import SwiftUI

struct SettingsView: View {
    @State private var showContributionCount: Bool
    @State private var showUsername: Bool
    @State private var username: String
    @State private var pollingRate: Double
    @State private var hasError = false
    @State private var errorMessage = ""

    let onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
        self.showContributionCount = UserDefaults.standard.bool(forKey: "showContributionCount")
        self.showUsername = UserDefaults.standard.bool(forKey: "showUsername")
        self.username =  UserDefaults.standard.string(forKey: "username") ?? ""
        self.pollingRate = UserDefaults.standard.double(forKey: "pollingRate")
        self.onDismiss = onDismiss
    }

    var body: some View {
            Form {
                Text("Settings")
                    .font(.title)
                TextField("GitHub username", text: $username)
                Toggle("Display username", isOn: $showUsername)
                    .toggleStyle(.switch)
                Toggle("Display contribution count", isOn: $showContributionCount)
                    .toggleStyle(.switch)
                TextField("Update rate (minutes)", value: $pollingRate, format: .number)
                HStack {
                    Button("Quit app") {
                        NSRunningApplication.current.terminate()
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                    Button("Cancel", role: .cancel, action: cancel)
                        .buttonStyle(.bordered)
                    Button("Save", action: save)
                        .buttonStyle(.borderedProminent)
                }
            }
            .alert("Invalid form", isPresented: $hasError) { } message: {
                Text(errorMessage)
            }
    }

    func cancel() {
        self.showContributionCount = UserDefaults.standard.bool(forKey: "showContributionCount")
        self.showUsername = UserDefaults.standard.bool(forKey: "showUsername")
        self.username =  UserDefaults.standard.string(forKey: "username") ?? ""
        self.pollingRate = UserDefaults.standard.double(forKey: "pollingRate")
        onDismiss()
    }

    func save() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else {
            errorMessage = "Username cannot be empty"
            hasError = true
            return
        }

        guard pollingRate >= 5 else {
            errorMessage = "Polling rate must be 5 minutes or higher"
            hasError = true
            pollingRate = 5
            return
        }

        UserDefaults.standard.set(showContributionCount, forKey: "showContributionCount")
        UserDefaults.standard.set(showUsername, forKey: "showUsername")
        UserDefaults.standard.set(trimmedUsername, forKey: "username")
        UserDefaults.standard.set(pollingRate, forKey: "pollingRate")
        onDismiss()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(onDismiss: {})
    }
}
