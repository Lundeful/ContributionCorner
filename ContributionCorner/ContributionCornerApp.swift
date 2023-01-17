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
        #if os(macOS)
        MenuBarExtra {
            ContentView()
        } label: {
            Label("Contribution Corner", systemImage: "square.grid.3x3.fill")
        }.menuBarExtraStyle(.window)
        
        Settings {
            Text("Settings")
        }
        #endif
    }
}
