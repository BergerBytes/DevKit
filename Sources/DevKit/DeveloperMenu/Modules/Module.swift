//
//  SwiftUIView.swift
//  
//
//  Created by Michael Berger on 12/23/22.
//

import SwiftUI


@available(iOS 15, *)
public protocol Module: AnyObject, Identifiable {
    associatedtype Body : View

    var id: String { get }
    
    @ViewBuilder @MainActor
    var content: Self.Body { get }
}
