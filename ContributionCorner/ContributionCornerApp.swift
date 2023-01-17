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
    
    init() {
        self.showContributionCount = UserDefaults.standard.bool(forKey: "showContributionCount")
        self.username =  UserDefaults.standard.string(forKey: "username") ?? ""
    }

    var body: some View {
        Form {
            TextField("GitHub username", text: $username)
            Toggle("Show contribution count", isOn: $showContributionCount)
                .toggleStyle(.switch)
        }
        .frame(maxWidth: 500, maxHeight: 500)
        .padding()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save", action: save)
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Button("Cancel", role: .cancel, action: closeWindow)
            }
        }
    }

    func save() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { return }

        UserDefaults.standard.set(showContributionCount, forKey: "showContributionCount")
        UserDefaults.standard.set(trimmedUsername, forKey: "username")
        closeWindow()
    }
    
    func closeWindow() {
        
    }
}
