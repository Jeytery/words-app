//
//  LightButton.swift
//  WordsApp
//
//  Created by Dmytro Ostapchenko on 13.10.2024.
//

import Foundation
import SwiftUI

struct LightButton: View {
    var tint: Color
    var title: String
    var iconName: String
    
    var body: some View {
        Button(action: {}) {
            Label(title, systemImage: iconName)
                .font(.system(size: 22, weight: .regular, design: .default))
                .foregroundColor(tint)
        }
        //.frame(width: .infinity, height: .infinity)
        .background(tint.opacity(0.1))
    }
}

fileprivate extension View {
    func onTouchDownGesture(callback: @escaping () -> Void, onEnd: @escaping () -> Void) -> some View {
        modifier(OnTouchDownGestureModifier(callback: callback, onEnd: onEnd))
    }
}

fileprivate struct OnTouchDownGestureModifier: ViewModifier {
    @State private var tapped = false
    let callback: () -> Void
    let onEnd: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !self.tapped {
                        self.tapped = true
                        self.callback()
                    }
                }
                .onEnded { _ in
                    self.tapped = false
                    onEnd()
                })
    }
}

struct LightButton2: View {
    init(title: String, imageName: String, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.imageName = imageName
        self.color = color
        self.action = action
        self.listBackgroundColor = color.opacity(0.1)
    }
    
    var title: String
    var imageName: String
    var color: Color
    var action: () -> Void
    
    @State private var listBackgroundColor: Color
    
    var body: some View {
        Button {

        } label: {
            HStack {
                Spacer()
                Image(systemName: imageName)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(color)
                    .font(.system(size: 17, weight: .regular, design: .default))
                Spacer()
            }
        }
    }
}



