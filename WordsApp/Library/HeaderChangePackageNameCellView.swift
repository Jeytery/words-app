//
//  HeaderChangePackageNameCellView.swift
//  WordsApp
//
//  Created by Dmytro Ostapchenko on 12.10.2024.
//

import Foundation
import SwiftUI

final class HeaderChangePackageNameCellViewState: ObservableObject {
    @Published var titleToChange: String = ""
}
struct HeaderChangePackageNameCellView: View {
    internal init(state: HeaderChangePackageNameCellViewState = .init()) {
        self.state = state
    }
    
    @ObservedObject private var state: HeaderChangePackageNameCellViewState
    
    var body: some View {
        HStack {
            Text(state.titleToChange)
                .foregroundColor(.secondary)
                .animation(.smooth, value: state.titleToChange)
            Spacer()
            Image(systemName: "pencil")
        }
    }
}
