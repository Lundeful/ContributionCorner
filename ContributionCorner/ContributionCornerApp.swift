//
//  ContributionCornerApp.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import SwiftUI
import FluidMenuBarExtra

@main
struct ContributionCornerApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        Settings {
            Text("Settings are located by pressing the gear icon inside the app")
        }
//        MenuBarExtra {
//            ContentView()
//        } label: {
//            Label("Contribution Corner", systemImage: "square.grid.3x3.fill")
//        }
//        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarExtra: FluidMenuBarExtra?

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.menuBarExtra = FluidMenuBarExtra(title: "Contribution Corner", systemImage: "square.grid.3x3.fill") {
            ContentView()
        }
    }
}
