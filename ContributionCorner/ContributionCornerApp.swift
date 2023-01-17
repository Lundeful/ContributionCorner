//
//  ContributionCornerApp.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import SwiftUI

@main
struct ContributionCornerApp: App {
    @State private var showSettings = false
    var body: some Scene {
//        WindowGroup {
//            Text("test")
//        }
        #if os(macOS)
        MenuBarExtra {
            ContentView()
        } label: {
            Label("Contribution Corner", systemImage: "square.grid.3x3.fill")
                .onTapGesture {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
        }.menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
        }
        .defaultSize(width: 300, height: 300)
        .defaultPosition(.center)
        #endif
    }
}

struct SettingsView: View {
    @State private var showContributionCount: Bool
    @State private var username: String
    @State private var pollingRate: Double
    
    init() {
        self.showContributionCount = UserDefaults.standard.bool(forKey: "showContributionCount")
        self.username =  UserDefaults.standard.string(forKey: "username") ?? ""
        self.pollingRate = UserDefaults.standard.double(forKey: "pollingRate")
    }

    var body: some View {
        Form {
            TextField("GitHub username", text: $username)
                .frame(maxWidth: 350)
            Toggle("Show contribution count", isOn: $showContributionCount)
                .toggleStyle(.switch)
            
            TextField("Update rate (minutes)", value: $pollingRate, format: .number)
            Spacer()
            HStack {
                Spacer()
                Button("Cancel", role: .cancel, action: closeWindow).buttonStyle(.bordered)
                Button("Save", action: save).buttonStyle(.borderedProminent)
            }
        }
        .frame(width: 400, height: 200)
        .padding()
    }

    func save() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { return } // TODO: Give warning
        guard pollingRate >= 5 else { return } // TODO: Give warning

        UserDefaults.standard.set(showContributionCount, forKey: "showContributionCount")
        UserDefaults.standard.set(trimmedUsername, forKey: "username")
        UserDefaults.standard.set(pollingRate, forKey: "pollingRate")
        closeWindow()
    }
    
    func closeWindow() {
        
    }
}
