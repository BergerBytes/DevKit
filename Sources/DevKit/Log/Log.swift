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
import os.log

public enum Log {
    public typealias Log = (message: String, params: [String: Any?]?)
    public typealias LogCallback = (Level, Log) -> Void
    public static var configuration = Configuration()
    public static var callback: LogCallback?
    
    @available(iOS 15, *)
    static var logModuleCallback: ((LogEntry) -> Void)?

    /// Storage for all local logs made via Loggable conforming objects.
    internal static var localLogs = [Int: [String]]()

    public struct Configuration {
        public let printToConsole: Bool
        public let printToOS: Bool
        public let blockAllLogs: Bool

        /// Should loggable object have their logs stored in memory.
        public let loggableEnabled: Bool

        // Number of logs to store per loggable object.
        public let loggableLimit: Int

        public init(
            printToConsole: Bool = true,
            printToOS: Bool = false,
            blockAllLogs: Bool = false,
            loggableEnabled: Bool = true,
            loggableLimit: Int = 50
        ) {
            self.printToConsole = printToConsole
            self.printToOS = printToOS
            self.blockAllLogs = blockAllLogs
            self.loggableEnabled = loggableEnabled
            self.loggableLimit = loggableLimit
        }
    }

    /// Extendable list of log types for a clear console and easy filtering.
    public struct Level: Equatable {
        public let symbol: String

        public init(_ symbol: String) {
            self.symbol = symbol
        }

        @available(*, deprecated, renamed: "init()")
        public init(prefix symbol: String) {
            self.symbol = symbol
        }

        public static let info = Level("⚪️")
        public static let standard = Level("🔵")
        public static let warning = Level("⚠️")
        public static let error = Level("❌")

        @available(macOS 10.12, *)
        @available(iOS 10.0, *)
        public var osLogType: OSLogType {
            switch self {
            case .info:
                return .info
            case .warning:
                return .fault
            case .error:
                return .error
            case .standard:
                return .debug
            default:
                return .debug
            }
        }
    }

    public struct Scope: Equatable, Hashable {
        public let symbol: Character
        public let name: String
        
        @available(*, deprecated, message: "Scope requires a name and symbols are limited to a single character", renamed: "init(_:name:)")
        public init(_ symbol: String) {
            self.symbol = symbol.first ?? Character("")
            self.name = ""
        }
        
        public init(_ symbol: Character, name: String) {
            self.symbol = symbol
            self.name = name
        }

        public static let database = Scope("💾", name: "Database")
        public static let auth = Scope("🔒", name: "Authentication")
        public static let connection = Scope("🌎", name: "Connection")
        public static let gps = Scope("🗺", name: "GPS")
        public static let startup = Scope("🎬", name: "Startup")
        public static let keychain = Scope("🔑", name: "Keychain")
        public static let payment = Scope("💳", name: "Payment")

        // The number types are only used for debugging.
        public static let one = Scope("1️⃣", name: "Debug 1")
        public static let two = Scope("2️⃣", name: "Debug 2")
        public static let three = Scope("3️⃣", name: "Debug 3")
    }
}

public extension Log {
    // MARK: - INFO

    @discardableResult
    @inlinable
    static func info(
        in scope: Scope? = nil,
        _ message: @autoclosure () -> Any?,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        log(.info, in: scope, message(), params: params(), file: file, function: function, line: line)
    }

    @discardableResult
    @inlinable
    static func info(
        in scope: Scope? = nil,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ message: () -> Any?
    ) -> String {
        info(in: scope, message(), params: params(), file: file, function: function, line: line)
    }

    // MARK: - DEBUG

    @discardableResult
    @inlinable
    static func debug(
        in scope: Scope? = nil,
        _ message: @autoclosure () -> Any?,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        log(.standard, in: scope, message(), params: params(), file: file, function: function, line: line)
    }

    @discardableResult
    @inlinable
    static func debug(
        in scope: Scope? = nil,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ message: () -> Any?
    ) -> String {
        debug(in: scope, message(), params: params(), file: file, function: function, line: line)
    }

    // MARK: - WARNING

    @discardableResult
    @inlinable
    static func warning(
        in scope: Scope? = nil,
        _ message: @autoclosure () -> Any?,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        log(.warning, in: scope, message(), params: params(), file: file, function: function, line: line)
    }

    @discardableResult
    @inlinable
    static func warning(
        in scope: Scope? = nil,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ message: () -> Any?
    ) -> String {
        warning(in: scope, message(), params: params(), file: file, function: function, line: line)
    }

    // MARK: - ERROR

    @discardableResult
    @inlinable
    static func error(
        in scope: Scope? = nil,
        _ message: @autoclosure () -> Any?,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        log(.error, in: scope, message(), params: params(), file: file, function: function, line: line)
    }

    @discardableResult
    @inlinable
    static func error(
        in scope: Scope? = nil,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ message: () -> Any?
    ) -> String {
        error(in: scope, message(), params: params(), file: file, function: function, line: line)
    }

    // MARK: - CUSTOM

    @discardableResult
    static func custom(
        _ level: Level,
        in scope: Scope? = nil,
        _ message: @autoclosure () -> Any?,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        log(level, in: scope, message(), params: params(), file: file, function: function, line: line)
    }

    @discardableResult
    static func custom(
        _ level: Level,
        in scope: Scope? = nil,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ message: () -> Any?
    ) -> String {
        custom(level, in: scope, message(), params: params(), file: file, function: function, line: line)
    }
}

extension Log {
    public static var subsystem = Bundle.main.bundleIdentifier ?? "unknown"

    @discardableResult
    @inlinable
    static func log(
        _ level: Level,
        in scope: Scope? = nil,
        _ message: @autoclosure () -> Any?,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        _log(level: level, in: scope, message(), params: params(), file: file, function: function, line: line)
    }

    @discardableResult
    @inlinable
    static func log(
        in scope: Scope? = nil,
        _ message: Any?,
        params: [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        _log(level: .standard, in: scope, message, params: params, file: file, function: function, line: line)
    }

    /// Logs the string representation of the message object to the console
    /// along with the type and location of the call.
    ///
    /// - Parameters:
    ///   - message: The object to log.
    ///   - type: The log type.
    ///
    /// ~~~
    /// Debug.log("Hello, World")
    /// Debug.log("Hello, World", level: .startup)
    /// ~~~
    @discardableResult
    public static func _log(
        level: Level,
        in scope: Scope? = nil,
        _ message: @autoclosure () -> Any?,
        params: @autoclosure () -> [String: Any?]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        if configuration.blockAllLogs {
            return ""
        }

        let evaluatedMessage = message()
        // Convert the message object to a string format. This will convert the same way Xcode would when debugging.
        let message = evaluatedMessage.map { String(describing: $0) } ?? String(describing: evaluatedMessage)

        let params = params()

        let paramsSpace = "\(params == nil ? "" : " ")"
        let paramsString = (params?
            .mapValues { value in value.map { String(describing: $0) } ?? "nil" })
            .map { String(describing: $0) } ?? ""

        // Extract the file name from the path.
        let callSite = formattedCallSite(file: file, function: function, line: line)

        let scopeString = scope.map { " \($0.symbol) " } ?? " "

        let printLog = configuration.printToConsole || configuration.printToOS
            ? "\(level.symbol)\(scopeString)\(message)\(paramsSpace)\(paramsString)  ->  \(callSite)"
            : ""

        // Print the log if we are debugging.
        if configuration.printToConsole {
            print(printLog)
        }

        // Send the log to the OS to allow for seeing logs when running on a disconnected device using Console.app
        if configuration.printToOS {
            if
                #available(macOS 10.12, *),
                #available(iOS 10.0, *)
            {
                let printLog = "\(level.symbol) \(message)\(paramsSpace)\(paramsString) ->  \(callSite)"
                os_log("%@", log: OSLog(subsystem: subsystem, category: file), type: level.osLogType, printLog)
            }
        }

        // Build the log; formatting the log into the desired format.
        // This could be expanded on for support for changing the format at runtime or per-developer.
        let log = "\(level.symbol) \(message) -> \(callSite)"

        // Invoke the log callback with the generated log
        callback?(level, (log, params))
        
        if #available(iOS 15, *) {
            logModuleCallback?(
                .init(
                    scope: scope,
                    level: level,
                    message: message,
                    params: params,
                    file: file,
                    function: function,
                    line: line
                )
            )
        }
        
        return log
    }
    
    /// Logs the return from the provided closure.
    ///
    /// - Parameters:
    ///   - type: The log type.
    ///   - computedMessage: Generate an object to log.
    ///
    /// - Note: This is useful when heavy calculations are required to generate the desired object to log. When running in a release build we want to avoid
    /// running those calculations. This log function will not execute in release mode.
    ///
    /// Consider the following example; Running the Fibonacci calculation would be a waste of cycles in release where the log would not be printed.
    /// ~~~
    /// Debug.log {
    ///     fib(1000)
    /// }
    ///
    /// Debug.log(type: .standard) {
    ///     fib(1000)
    /// }
    /// ~~~
    @discardableResult
    @inlinable
    static func log(
        _ level: Level = .standard,
        in scope: Scope? = nil,
        _ computedMessage: () -> Any?,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        if configuration.blockAllLogs {
            return ""
        }

        return log(level, in: scope, computedMessage(), params: nil, file: file, function: function, line: line)
    }

    /// A convenience log to automatically use the localizedDescription of the given error.
    ///
    /// - Parameters:
    ///   - error: The error to log.
    @discardableResult
    @inlinable
    static func log(
        error: Error?,
        in scope: Scope? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        guard let error else { return "" }

        return log(
            .error,
            in: scope,
            { error },
            file: file,
            function: function,
            line: line
        )
    }
}

public extension Log {
    @inlinable
    static func fileName(in path: String) -> String {
        // Extract the file name from the path.
        let fileString = path as NSString
        let fileLastPathComponent = fileString.lastPathComponent as NSString
        return fileLastPathComponent.deletingPathExtension
    }
    
    @inlinable
    static func formattedCallSite(file: String, function: String, line: Int) -> String {
        "\(fileName(in: file)).\(function) [\(line)]"
    }
}
