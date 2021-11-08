import Foundation
import os.log

extension Debug {
    public struct Log {
        public typealias LogCallback = (Level, String) -> Void
        public static var configuration = Configuration()
        public static var callback: LogCallback?
        
        /// Storage for all local logs made via Loggable conforming objects.
        internal static var localLogs = [Int: [String]]()

        public struct Configuration {
            
            let printToConsole: Bool
            let printToOS: Bool
            let blockAllLogs: Bool
            
            /// Should loggable object have their logs stored in memory.
            let loggableEnabled: Bool
            
            // Number of logs to store per loggable object.
            let loggableLimit: Int
                        
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
            public let prefix: String
            
            public init(prefix: String) {
                self.prefix = prefix
            }
            
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
    /// - Warning: The computed property version of log is recommended. This will likely be deprecated in the future. See ``log(level:_:file:function:line:)``
    @discardableResult
    public static func log( _ message: Any?,
                            level: Log.Level = .standard,
                            file: String     = #file,
                            function: String = #function,
                            line: Int        = #line) -> String {
        
        if Log.configuration.blockAllLogs {
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
        if Log.configuration.printToConsole {
            print(log)
        }
        
        // Send the log to the OS to allow for seeing logs when running on a disconnected device using Console.app
        if Log.configuration.printToOS {
            if
                #available(macOS 10.12, *),
                #available(iOS 10.0, *)
            {
                os_log("%@", log: OSLog(subsystem: subsystem, category: file), type: level.osLogType, log)
            }
        }
        
        // Invoke the log callback with the generated log
        Log.callback?(level, log)
        
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
        
        if Log.configuration.blockAllLogs {
            return ""
        }
        
        return log(computedMessage(), level: level, file: file, function: function, line: line)
    }
    
    /// A convenience log to automatically use the localizedDescription of the given error.
    ///
    /// - Parameters:
    ///   - error: The error to log.
    @discardableResult
    public static func log(error: Error?,
                           file: String     = #file,
                           function: String = #function,
                           line: Int        = #line) -> String {
        guard let error = error else { return "" }
        
        return log(
            level: .error,
            { error },
            file: file,
            function: function,
            line: line
        )
    }
}
