//
//  ContributionCornerApp.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import SwiftUI

@main
struct ContributionCornerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        Settings {
            EmptyView()
//            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        popover.behavior = .transient
        popover.animates = true

        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: ContributionsView())
        popover.contentSize = .init(width: 900, height: 500)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let menuButton = statusItem?.button {
            menuButton.image = NSImage(systemSymbolName: "square.grid.3x3.fill", accessibilityDescription: nil)
            menuButton.action = #selector(togglePopover)
        }
    }

    @objc func togglePopover(sender: AnyObject) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover()
        }
    }

    func showPopover() {
        if let menuButton = statusItem?.button {
            self.popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
            
            // This makes it close when clicking outside of the popover
            // TODO: Allow settings change to disable this feature
            popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    func closePopover(sender: AnyObject) {

    }
}
