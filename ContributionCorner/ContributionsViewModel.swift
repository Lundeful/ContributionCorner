
import SwiftUI
@MainActor
final class ContributionsViewModel: ObservableObject {
    @AppStorage("username") var username = ""
    @Published var contributions: [Date] = []
    @Published var isInitialLoad = true
    @Published var isFetching = false
    @Published var errorMessage = ""

    init(autoFetch: Bool = true) {
        if autoFetch {
            Task { await getContributions() }
        }
    }

    func getContributions() async {
        guard !self.username.isEmpty else {
            self.contributions = []
            self.isFetching = false
            self.isInitialLoad = false
            return
        }

        self.isFetching = true
        self.errorMessage = ""

        do {
            let result = try await GithubParser.getContributions(for: self.username)
            self.contributions = result
            print("Successfully fetched contributions")
        } catch let error as NetworkError {
            self.contributions = []
            self.errorMessage = error.localizedDescription
            print(error.localizedDescription)
        } catch {
            self.contributions = []
            self.errorMessage = "An unknown error occurred"
            print("Unknown error: \(error.localizedDescription)")
        }

        self.isFetching = false
        self.isInitialLoad = false
    }
}
