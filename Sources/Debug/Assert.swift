//  Copyright © 2021 BergerBytes LLC. All rights reserved.
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

public extension Debug {
    enum Assert {
        public static var configuration = Configuration()

        public struct Configuration {
            public let throwAssertionFailures: Bool

            public init(throwAssertionFailures: Bool = true) {
                self.throwAssertionFailures = throwAssertionFailures
            }
        }
    }

    static func assert(
        _ assertion: () -> Bool,
        message: Any?,
        params: [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        Self.assert(
            assertion(),
            message: message,
            params: params,
            file: file,
            function: function,
            line: line
        )
    }

    static func assert(
        _ assertion: Bool,
        message: Any?,
        params: [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        if assertion {
            return
        }

        assertionFailure(
            message,
            params: params,
            file: file,
            function: function,
            line: line
        )
    }

    static func assertionFailure(
        scope: Log.Scope? = nil,
        _ message: Any?,
        params: [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let log = Debug.log(
            .error,
            in: scope,
            message,
            params: params,
            file: file,
            function: function,
            line: line
        )

        if Assert.configuration.throwAssertionFailures {
            Swift.assertionFailure(log)
        }
    }
}
