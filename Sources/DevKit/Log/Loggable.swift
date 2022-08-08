/// Object that will have its logs stored for easier debugging.
/// Access .logs when debugging to see a list of all the most recent logs.
public protocol Loggable: Hashable { }

public extension Loggable {
    @discardableResult
    func log(
        _ level: Log.Level = .standard,
        in scope: Log.Scope? = nil,
        _ computedMessage: @escaping () -> Any?,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        Self.add(
            log: Log.log(level, in: scope, computedMessage, file: file, function: function, line: line),
            to: hashValue
        )
    }

    var logs: [String] {
        Log.localLogs[hashValue, default: []]
    }

    private static func add(log: String, to id: Int) -> String {
        guard
            Log.configuration.blockAllLogs == false,
            Log.configuration.loggableEnabled
        else {
            return log
        }

        var array = Log.localLogs[id, default: []]

        array.append(log)

        if array.count > Log.configuration.loggableLimit {
            array.removeFirst()
        }

        Log.localLogs[id] = array
        return log
    }
}
