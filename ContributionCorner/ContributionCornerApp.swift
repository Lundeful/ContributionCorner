import SwiftUI

@main
struct ContributionCornerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var viewModel: ContributionsViewModel?
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    var iconObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        viewModel = ContributionsViewModel(autoFetch: false)

        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateMenuBarIconFromPreferences()

        iconObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateMenuBarIconFromPreferences()
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
            // Initialize popover content only when needed
            if popover.contentViewController == nil {
                popover.contentViewController = NSViewController()
                popover.contentViewController?.view = NSHostingView(
                    rootView: ContributionsView(viewModel: viewModel!)
                )
                popover.contentSize = NSSize(width: 900, height: 500)
            }

            self.popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
            // Enable clicking outside to dismiss
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func closePopover(sender: AnyObject) {
        popover.performClose(sender)
    }

    func popoverWillShow(_ notification: Notification) {
        Task {
            await viewModel?.getContributions()
        }
    }

    func updateMenuBarIconFromPreferences() {
        let useCustomIcon = UserDefaults.standard.bool(forKey: "useCustomIcon")

        if useCustomIcon {
            if let localIconPath = UserDefaults.standard.string(forKey: "localIconPath"), !localIconPath.isEmpty {
                updateMenuBarWithLocalIcon(path: localIconPath)
            } else {
                let defaultIcon = "square.grid.3x3.fill"
                updateMenuBarIcon(iconName: defaultIcon)
            }
        } else {
            updateMenuBarIcon(iconName: "square.grid.3x3.fill")
        }
    }

    func updateMenuBarIcon(iconName: String) {
        if let menuButton = statusItem?.button {
            menuButton.image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
            menuButton.action = #selector(togglePopover)
        }
    }

    func updateMenuBarWithLocalIcon(path: String) {
        guard let menuButton = statusItem?.button else { return }

        if let image = NSImage(contentsOfFile: path) {
            let resizedImage = resizeImage(image: image, to: NSSize(width: 18, height: 18))

            menuButton.image = resizedImage
            menuButton.action = #selector(togglePopover)
        } else {
            print("Failed to load local icon from path: \(path)")
            menuButton.image = NSImage(systemSymbolName: "square.grid.3x3.fill", accessibilityDescription: nil)
            menuButton.action = #selector(togglePopover)
        }
    }

    func resizeImage(image: NSImage, to size: NSSize) -> NSImage {
        let resizedImage = NSImage(size: size)

        resizedImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(origin: .zero, size: size),
                  from: NSRect(origin: .zero, size: image.size),
                  operation: .copy,
                  fraction: 1.0)
        resizedImage.unlockFocus()

        return resizedImage
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let observer = iconObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
