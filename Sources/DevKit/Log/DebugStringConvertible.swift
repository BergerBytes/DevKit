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

@propertyWrapper
public struct IgnoreDebugStringConvertible<Value> {
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value
}

/// Default implementation of CustomDebugStringConvertible to allow for easy printing to the console.
public protocol DevKitDebugStringConvertible: CustomDebugStringConvertible { }

public extension DevKitDebugStringConvertible {
    var debugDescription: String {
        var description = "\(type(of: self)):\n"

        let mirror = Mirror(reflecting: self)

        for child in mirror.children {
            if let propertyName = child.label {
                var childValue = "\(child.value)"

                /// Exclude properties wrapped with ``IgnoreDebugStringConvertible``
                if propertyName.first == "_" && childValue.contains("IgnoreDebugStringConvertible") {
                    continue
                }
                
                let typeName = "\(type(of: child.value))"
                if typeName.contains("Array") || typeName.contains("Dictionary") || typeName.contains("Set"), childValue != "[]" {
                    childValue = childValue.replacingOccurrences(of: "[", with: "[\n ")
                    childValue = childValue.replacingOccurrences(of: "]", with: "\n]")
                    childValue = childValue.replacingOccurrences(of: ", ", with: ",\n ")
                }

                if childValue.contains("\n") {
                    childValue = childValue.replacingOccurrences(of: "\n", with: "\n    ")
                }

                description += "    \(propertyName): \(childValue)\n"
            }
        }

        return description
    }
}
