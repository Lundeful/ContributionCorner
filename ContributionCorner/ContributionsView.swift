//
//  ContributionsView.swift
//  ContributionCorner
//
//  Created by Christoffer Lund on 17/01/2023.
//

import SwiftUI
import AxisContribution
import Combine

struct ContributionsView: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var viewModel: ContributionsViewModel

    var body: some View {
        VStack(alignment: .center) {
            Toolbar(viewModel: viewModel)
            if viewModel.username.isEmpty {
                Text("Enter your GitHub username in the settings to get started")
                    .frame(height: 150)
            } else if viewModel.isInitialLoad {
                ProgressView()
                    .frame(height: 150)
            }
            else {
                AxisContribution(constant: .init(), source: viewModel.contributions) { indexSet, data in
                    RoundedRectangle(cornerRadius: 2)
                        .foregroundColor(colorScheme == .dark ? Theme.darkBackgroundColor : Theme.lightBackgroundColor)
                        .frame(width: Theme.rowSize, height: Theme.rowSize)
                } foreground: { indexSet, data in
                    if let data {
                        RoundedRectangle(cornerRadius: 2)
                            .foregroundColor(Theme.foregroundColor)
                            .frame(width: Theme.rowSize, height: Theme.rowSize)
                            .help("\(data.count.formatted()) contribution\(data.count == 1 ? "" : "s") on \(data.date.formatted(date: .abbreviated, time: .omitted))")
                    } else {
                        // This will be part of the less/more boxes beneath the graph
                        RoundedRectangle(cornerRadius: 2)
                            .foregroundColor(Theme.foregroundColor)
                            .frame(width: Theme.rowSize, height: Theme.rowSize)
                    }
                }
                .id(viewModel.contributions) // This fixes bug where AxisContribution graph does not update
                .frame(height: 150)
            }
            if !viewModel.errorMessage.isEmpty {
                HStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Error occured while fetching contribution data")
                    Spacer()
                }
            }
        }
        .frame(width: 830)
        .padding()
    }
}

struct ContributionsView_Previews: PreviewProvider {
    static var previews: some View {
        ContributionsView(viewModel: ContributionsViewModel())
    }
}
