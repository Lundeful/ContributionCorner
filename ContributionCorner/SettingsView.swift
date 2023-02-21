//
//  SettingsView.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @State private var showContributionCount: Bool
    @State private var showUsername: Bool
    @State private var username: String
    @State private var pollingRate: Double
    @State private var hasError = false
    @State private var launchOnStartup: Bool = false
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
                TextField("Update rate (minutes)", value: $pollingRate, format: .number)
                Toggle("Display username", isOn: $showUsername)
                    .toggleStyle(.switch)
                Toggle("Display contribution count", isOn: $showContributionCount)
                    .toggleStyle(.switch)

                if #available(macOS 13, *) {
                    Toggle("Launch on startup", isOn: $launchOnStartup)
                        .toggleStyle(.switch)
                }

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
            .onAppear {
                // Somehow this wouldn't trigger properly inside the init function, but works here
                // TODO: Figure out why
                if #available(macOS 13, *) {
                    self.launchOnStartup = SMAppService.mainApp.status == .enabled
                }
            }
    }

    func cancel() {
        onDismiss()
    }

    func save() {
        clearError()

        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else {
            errorMessage = "Username cannot be empty"
            hasError = true
            return
        }

        guard pollingRate >= 5 else {
            errorMessage = "Polling rate must be 5 minutes or higher to prevent spam"
            hasError = true
            pollingRate = 5
            return
        }

        UserDefaults.standard.set(showContributionCount, forKey: "showContributionCount")
        UserDefaults.standard.set(showUsername, forKey: "showUsername")
        UserDefaults.standard.set(trimmedUsername, forKey: "username")
        UserDefaults.standard.set(pollingRate, forKey: "pollingRate")

        updateLaunchAtStartup()

        if errorMessage.isEmpty && !hasError {
            onDismiss()
        }
    }

    func updateLaunchAtStartup() {
        if #available(macOS 13, *) {
            let currentStatus = SMAppService.mainApp.status

            if launchOnStartup && currentStatus != .enabled {
                enableLaunchAtStartup()
            } else if !launchOnStartup && currentStatus == .enabled {
                disableLaunchAtStartup()
            }
        }
    }

    func enableLaunchAtStartup() {
        if #available(macOS 13, *) {
            do {
                try SMAppService.mainApp.register()
            } catch {
                setError(withMessage: "Failed to add launch at login: " + error.localizedDescription)
            }
        }
    }

    func disableLaunchAtStartup() {
        if #available(macOS 13, *) {
            do {
                try SMAppService.mainApp.unregister()
            } catch {
                setError(withMessage: "Failed to remove launch at login: " + error.localizedDescription)
            }
        }
    }

    func setError(withMessage message: String) {
        errorMessage = message
        hasError = true
    }

    func clearError() {
        errorMessage = ""
        hasError = false
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(onDismiss: {})
    }
}
