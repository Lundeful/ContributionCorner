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
    
    init() {
        self.showContributionCount = UserDefaults.standard.bool(forKey: "showContributionCount")
        self.showUsername = UserDefaults.standard.bool(forKey: "showUsername")
        self.username =  UserDefaults.standard.string(forKey: "username") ?? ""
        self.pollingRate = UserDefaults.standard.double(forKey: "pollingRate")
    }

    var body: some View {
        VStack {
            Form {
                TextField("GitHub username", text: $username)
                Toggle("Show contribution count", isOn: $showContributionCount)
                    .toggleStyle(.switch)
                
                TextField("Update rate (minutes)", value: $pollingRate, format: .number)
            }
            Spacer()
            HStack {
                Button("Quit") {
                    NSRunningApplication.current.terminate()
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Cancel", role: .cancel, action: closeWindow)
                    .buttonStyle(.bordered)
                Button("Save", action: save)
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(width: 400, height: 200)
        .padding()
        .alert("Invalid form", isPresented: $hasError) { } message: {
            Text(errorMessage)
        }
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
        closeWindow()
    }
    
    func closeWindow() {
        NSApplication.shared.keyWindow?.close()
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
