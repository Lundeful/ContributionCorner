//
//  Toolbar.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 19/06/2023.
//

import SwiftUI

struct Toolbar: View {
    @ObservedObject var viewModel: ContributionsViewModel
    @State private var showingSettings = false

    var usernameView: some View {
        HStack {
            Spacer()
            Text(viewModel.username)
            if !viewModel.username.isEmpty {
                Link(destination: URL(string: "https://github.com/\(viewModel.username)")!) {
                    Image(systemName: "link")
                }
                .focusable(false)
                .foregroundColor(.primary)
            }
            Spacer()
        }
    }

    var refreshButton: some View {
        Button {
            Task {
                await viewModel.getContributions()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .buttonStyle(.plain)
        .focusable(false) // Removes focus ring, TODO: find alternative solution
    }

    var settingsButton: some View {
        Button {
            showingSettings.toggle()
        } label: {
            Image(systemName: "gear")
        }
        .buttonStyle(.plain)
        .focusable(false) // Removes focus ring, TODO: find alternative solution
    }

    var body: some View {
        VStack {
            ZStack {
                usernameView
                HStack {
                    Text("\(viewModel.contributions.count) contribution\(viewModel.contributions.count == 1 ? "" : "s")")
                        .redacted(reason: viewModel.isInitialLoad ? .placeholder : [])
                    Spacer()
                    refreshButton
                    settingsButton
                }
            }
            if showingSettings {
                SettingsView(onDismiss: {
                    showingSettings = false
                    Task {
                        await viewModel.getContributions()
                    }
                })
            }
        }
    }
}
