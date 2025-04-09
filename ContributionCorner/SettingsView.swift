
import SwiftUI
import ServiceManagement
import UniformTypeIdentifiers
import Foundation

struct SettingsView: View {
    @AppStorage("username") var username = ""
    @AppStorage("menuBarIcon") var menuBarIcon = "square.grid.3x3.fill"
    @AppStorage("useCustomIcon") var useCustomIcon = false
    @AppStorage("localIconPath") var localIconPath = ""
    @State private var launchOnStartup = false
    @State private var hasError = false
    @State private var errorMessage = ""
    @State private var showingFilePicker = false

    let systemIcon = "square.grid.3x3.fill"

    let onDismiss: () -> Void

    var body: some View {
        Form {
            Text("Settings")
                .font(.title)
            TextField("GitHub username", text: $username)

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

            VStack(alignment: .leading) {
                Text("Menu Bar Icon")
                    .font(.headline)

                Picker("Icon Type", selection: $useCustomIcon) {
                    Text("System Icon").tag(false)
                    Text("Custom Icon").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 5)

                if useCustomIcon {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            if !localIconPath.isEmpty {
                                if let image = NSImage(contentsOfFile: localIconPath) {
                                    Image(nsImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 44, height: 44)
                                } else {
                                    Text("Invalid image")
                                        .foregroundColor(.red)
                                }
                            } else {
                                Text("No image selected")
                                    .foregroundColor(.secondary)
                            }

                            Button("Choose Image...") {
                                showingFilePicker = true
                            }
                            .buttonStyle(.bordered)
                        }

                        Text("Select an image file (PNG recommended)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: systemIcon)
                                .font(.system(size: 20))
                                .frame(width: 44, height: 44)
                                .background(Color.accentColor.opacity(0.3))
                                .cornerRadius(8)

                            Text("Using default 3.3 grid icon")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                    .onAppear {
                        menuBarIcon = systemIcon
                    }
                }
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
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.png, .jpeg],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    if url.startAccessingSecurityScopedResource() {
                        defer {
                            url.stopAccessingSecurityScopedResource()
                        }

                        if NSImage(contentsOf: url) != nil {
                            if let localURL = copyImageToLocalStorage(from: url) {
                                localIconPath = localURL.path
                            } else {
                                setError(withMessage: "Failed to copy image to local storage")
                            }
                        } else {
                            setError(withMessage: "Failed to load image: The selected file is not a valid image")
                        }
                    } else {
                        setError(withMessage: "Failed to access file: Permission denied")
                    }
                }
            case .failure(let error):
                setError(withMessage: "Failed to select file: \(error.localizedDescription)")
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
            setError(withMessage: "Username cannot be empty")
            return
        }

        if errorMessage.isEmpty && !hasError {
            UserDefaults.standard.set(trimmedUsername, forKey: "username")
            updateLaunchAtStartup()
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

    func getCustomIconsDirectory() -> URL? {
        let fileManager = FileManager.default

        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("Failed to get Application Support directory")
            return nil
        }

        let appDirectoryURL = appSupportURL.appendingPathComponent("ContributionCorner", isDirectory: true)
        if !fileManager.fileExists(atPath: appDirectoryURL.path) {
            do {
                try fileManager.createDirectory(at: appDirectoryURL, withIntermediateDirectories: true)
            } catch {
                print("Failed to create app directory: \(error.localizedDescription)")
                return nil
            }
        }

        let iconsDirectoryURL = appDirectoryURL.appendingPathComponent("CustomIcons", isDirectory: true)
        if !fileManager.fileExists(atPath: iconsDirectoryURL.path) {
            do {
                try fileManager.createDirectory(at: iconsDirectoryURL, withIntermediateDirectories: true)
            } catch {
                print("Failed to create custom icons directory: \(error.localizedDescription)")
                return nil
            }
        }

        return iconsDirectoryURL
    }

    func copyImageToLocalStorage(from sourceURL: URL) -> URL? {
        guard let iconsDirectory = getCustomIconsDirectory() else {
            print("Failed to get custom icons directory")
            return nil
        }

        let fileManager = FileManager.default

        do {
            let existingFiles = try fileManager.contentsOfDirectory(at: iconsDirectory, includingPropertiesForKeys: nil)
            for fileURL in existingFiles {
                try fileManager.removeItem(at: fileURL)
                print("Deleted old icon: \(fileURL.lastPathComponent)")
            }
        } catch {
            print("Error while cleaning up old icons: \(error.localizedDescription)")
        }

        let fileExtension = sourceURL.pathExtension
        let newFilename = "custom_icon.\(fileExtension)"
        let destinationURL = iconsDirectory.appendingPathComponent(newFilename)

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("Saved new icon: \(destinationURL.lastPathComponent)")
            return destinationURL
        } catch {
            print("Failed to copy image to local storage: \(error.localizedDescription)")
            return nil
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(onDismiss: {})
    }
}
