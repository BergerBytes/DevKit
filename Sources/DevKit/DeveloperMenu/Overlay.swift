//
//  File.swift
//  
//
//  Created by Michael Berger on 12/23/22.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
extension DeveloperMenu {
    public struct Overlay: View {
        @State private var visible = false
        @State private var showDebugMenu = false
        @State private var debugMenuButtonPosition = CGPoint.zero
        
        public init() { }
        
        public var body: some View {
            GeometryReader { proxy in
                ZStack(alignment: .bottomTrailing) {
                    Button {
                        showDebugMenu.toggle()
                    } label: {
                        Image(systemName: "ladybug.fill")
                            .padding()
                            .background(.regularMaterial, in: Circle())
                    }
                    .opacity(visible ? 1 : 0)
                    .animation(.default, value: visible)
                    .font(.title)
                    .buttonStyle(.borderless)
                    .buttonBorderShape(.capsule)
                    .position(debugMenuButtonPosition)
                    .highPriorityGesture(
                        DragGesture().onChanged { drag in
                            withAnimation {
                                debugMenuButtonPosition = drag.location
                            }
                        }
                    )
                }
                .onAppear {
                    debugMenuButtonPosition = .init(
                        x: proxy.size.width - proxy.safeAreaInsets.trailing - 50,
                        y: proxy.size.height - proxy.safeAreaInsets.bottom - 50
                    )
                    Task { @MainActor in
                        visible = true
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .devKitMenu(isPresented: $showDebugMenu)
        }
    }
}

@available(iOS 15.0, *)
struct Overlay_Previews: PreviewProvider {
    static var show = false
    static var previews: some View {
        DeveloperMenu.Overlay()
    }
}
