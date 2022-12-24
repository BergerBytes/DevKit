//  Copyright © 2022 BergerBytes LLC. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED  AS IS AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

import Foundation
import SwiftUI

@available(iOS 15.0, *)
public enum DeveloperMenu {
    private static var modules: [any Module] = []
    static func present() { }
    
    static public func register(module: any (Module.Type)) throws {
        guard !modules.contains(where: { type(of: $0) == module }) else {
            throw Error.moduleAlreadyRegistered
        }
        modules.append(module.init())
    }
}

@available(iOS 15.0, *)
extension DeveloperMenu {
    public enum Error: LocalizedError {
        case moduleAlreadyRegistered
    }
}

@available(iOS 15.0, *)
extension DeveloperMenu {
    public struct MainView: View {
        public var body: some View {
            NavigationView {
                List {
                    ForEach(DeveloperMenu.modules, id: \.id) { module in
                        NavigationLink(module.id) {
                           AnyView(module.content)
                                .navigationTitle(module.id)
                        }
                    }
                }
                .navigationTitle("DevKit")
            }
        }
    }
}

@available(iOS 15.0, *)
struct DeveloperMenu_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperMenu.MainView()
    }
}
