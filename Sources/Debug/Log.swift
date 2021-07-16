import Foundation
import os.log

extension Debug {
    public struct Log {
        public struct Configuration {
            let printToConsole: Bool = true
            let printToOS: Bool = true
            let blockAllLogs: Bool = false
        }
        
        /// Extendable list of log types for a clear console and easy filtering.
        public struct Level: Equatable {
            public let prefix: String
            
            public static let standard   = Level(prefix: "🔵")
            public static let low        = Level(prefix: "⚫️")
            public static let warning    = Level(prefix: "⚠️")
            public static let error      = Level(prefix: "❌")
            public static let database   = Level(prefix: "💾")
            public static let auth       = Level(prefix: "🔒")
            public static let connection = Level(prefix: "🌎")
            public static let gps        = Level(prefix: "🗺")
            public static let startup    = Level(prefix: "🎬")
            public static let keychain   = Level(prefix: "🔑")
            public static let payment    = Level(prefix: "💳")
            
            // The number types are only used for debugging.
            public static let one        = Level(prefix: "1️⃣")
            public static let two        = Level(prefix: "2️⃣")
            public static let three      = Level(prefix: "3️⃣")
            
            @available(macOS 10.12, *)
            @available(iOS 10.0, *)
            var osLogType: OSLogType {
                switch self {
                case .low:
                    return .info
                case .warning:
                    return .fault
                case .error:
                    return .error
                default:
                    return .debug
                }
            }
        }
    }
}

extension Debug {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    public static var configuration = Debug.Log.Configuration()
    
    
    /// Logs the string representation of the message object to the console
    /// along with the type and location of the call.
    ///
    /// - Parameters:
    ///   - message: The object to log.
    ///   - type: The log type.
    ///
    /// ~~~
    /// Debug.log("Hello, World")
    /// Debug.log("Hello, World", type: .startup)
    /// ~~~
    @discardableResult
    public static func log( _ message: Any?,
                            level: Log.Level = .standard,
                            file: String     = #file,
                            function: String = #function,
                            line: Int        = #line) -> String {
        
        if configuration.blockAllLogs {
            return ""
        }
        
        // Convert the message object to a string format. This will convert the same way Xcode would when debugging.
        let message = message.map { String(describing: $0) } ?? String(describing: message)
        
        // Extract the file name from the path.
        let fileString = file as NSString
        let fileLastPathComponent = fileString.lastPathComponent as NSString
        let fileName = fileLastPathComponent.deletingPathExtension
        
        // Build the log; formatting the log into the desired format.
        // This could be expanded on for support for changing the format at runtime or per-developer.
        let log = "\(level.prefix) \(message)  ->  \(fileName).\(function) [\(line)]"
        
        // Print the log if we are debugging.
        if configuration.printToConsole {
            print(log)
        }
        
        // Send the log to the OS to allow for seeing logs when running on a disconnected device using Console.app
        if configuration.printToOS {
            if
                #available(macOS 10.12, *),
                #available(iOS 10.0, *)
            {
                os_log("%@", log: OSLog(subsystem: subsystem, category: file), type: level.osLogType, log)
            }
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
    public static func log(level: Log.Level   = .standard,
                           _ computedMessage: () -> Any?,
                           file: String       = #file,
                           function: String   = #function,
                           line: Int          = #line) -> String {
        
        if configuration.blockAllLogs {
            return ""
        }
        
        return log(computedMessage(), level: level, file: file, function: function, line: line)
    }
    
    /// A convenience log to automatically use the localizedDescription of the given error.
    ///
    /// - Parameters:
    ///   - error: The error to log.
    public static func log(error: Error?,
                           file: String     = #file,
                           function: String = #function,
                           line: Int        = #line) {
        guard let error = error else { return }
        
        log(error.localizedDescription,
            level: .error,
            file: file,
            function: function,
            line: line)
    }
}
