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
import OrderedCollections

public enum Assert {
    public static var configuration = Configuration()

    public struct Configuration {
        public var throwAssertionFailures: Bool = true
        public var checkAssertions: Bool = true

        public init(throwAssertionFailures: Bool = true, checkAssertions: Bool = true) {
            self.throwAssertionFailures = throwAssertionFailures
            self.checkAssertions = checkAssertions
        }
    }

    // MARK: - True

    @inlinable
    public static func isTrue(
        _ assertion: () -> Bool,
        in scope: Log.Scope? = nil,
        message: Any?,
        info: OrderedDictionary<String, Any?>? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard Assert.configuration.checkAssertions else {
            return
        }

        isTrue(
            assertion(),
            in: scope,
            message: message,
            info: info,
            file: file,
            function: function,
            line: line
        )
    }

    @inlinable
    public static func isTrue(
        _ assertion: @autoclosure () -> Bool,
        in scope: Log.Scope? = nil,
        message: Any?,
        info: OrderedDictionary<String, Any?>? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard Assert.configuration.checkAssertions else {
            return
        }

        if assertion() {
            return
        }

        failure(
            in: scope,
            message,
            info: info,
            file: file,
            function: function,
            line: line
        )
    }

    // MARK: - False

    @inlinable
    public static func isFalse(
        in scope: Log.Scope? = nil,
        message: Any?,
        _ assertion: () -> Bool,
        info: OrderedDictionary<String, Any?>? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard Assert.configuration.checkAssertions else {
            return
        }

        isFalse(
            assertion(),
            in: scope,
            message: message,
            info: info,
            file: file,
            function: function,
            line: line
        )
    }

    @inlinable
    public static func isFalse(
        _ assertion: @autoclosure () -> Bool,
        in scope: Log.Scope? = nil,
        message: Any?,
        info: OrderedDictionary<String, Any?>? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard Assert.configuration.checkAssertions else {
            return
        }

        if !assertion() {
            return
        }

        failure(
            in: scope,
            message,
            info: info,
            file: file,
            function: function,
            line: line
        )
    }

    // MARK: - Equals

    @inlinable
    public static func isEqual<Value: Equatable>(
        _ assertion: () -> Value,
        to value: Value,
        in scope: Log.Scope? = nil,
        message: Any?,
        info: OrderedDictionary<String, Any?>? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard Assert.configuration.checkAssertions else {
            return
        }

        isEqual(
            assertion(),
            to: value,
            in: scope,
            message: message,
            info: info,
            file: file,
            function: function,
            line: line
        )
    }

    @inlinable
    public static func isEqual<Value: Equatable>(
        _ assertion: @autoclosure () -> Value,
        to value: Value,
        in scope: Log.Scope? = nil,
        message: Any?,
        info: OrderedDictionary<String, Any?>? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard Assert.configuration.checkAssertions else {
            return
        }

        if value == assertion() {
            return
        }

        failure(
            in: scope,
            message,
            info: info,
            file: file,
            function: function,
            line: line
        )
    }

    // MARK: - Nil / Not Nil

    @inlinable
    public static func isNil(
        _ assertion: @autoclosure () -> Any?,
        in scope: Log.Scope? = nil,
        message: Any?,
        info: OrderedDictionary<String, Any?>? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard Assert.configuration.checkAssertions else {
            return
        }

        if assertion() == nil {
            return
        }

        failure(
            in: scope,
            message,
            info: info,
            file: file,
            function: function,
            line: line
        )
    }

    @inlinable
    public static func isNotNil(
        _ assertion: @autoclosure () -> Any?,
        in scope: Log.Scope? = nil,
        message: Any?,
        info: OrderedDictionary<String, Any?>? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard Assert.configuration.checkAssertions else {
            return
        }

        if assertion() != nil {
            return
        }

        failure(
            in: scope,
            message,
            info: info,
            file: file,
            function: function,
            line: line
        )
    }

    // MARK: - Failure

    @inlinable
    public static func failure(
        in scope: Log.Scope? = nil,
        _ message: Any?,
        info: OrderedDictionary<String, Any?>? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        if Assert.configuration.throwAssertionFailures {
            Swift.assertionFailure(Log.custom(
                .error,
                in: scope,
                message,
                info: info,
                file: file,
                function: function,
                line: line
            ))
        }
    }
}
