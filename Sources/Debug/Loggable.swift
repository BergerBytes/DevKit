/// Object that will have its logs stored for easier debugging.
/// Access .logs when debugging to see a list of all the most recent logs.
public protocol DebugLoggable: Hashable { }

public extension DebugLoggable {
    @discardableResult
    func log(
        _ level: Debug.Log.Level = .standard,
        in scope: Debug.Log.Scope? = nil,
        _ computedMessage: @escaping () -> Any?,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        Self.add(
            log: Debug.log(level, in: scope, computedMessage, file: file, function: function, line: line),
            to: hashValue
        )
    }

    @discardableResult
    func log(
        error: Error?,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        Self.add(
            log: Debug.log(error: error, file: file, function: function, line: line),
            to: hashValue
        )
    }

    var logs: [String] {
        Debug.Log.localLogs[hashValue, default: []]
    }

    private static func add(log: String, to id: Int) -> String {
        guard
            Debug.Log.configuration.blockAllLogs == false,
            Debug.Log.configuration.loggableEnabled
        else {
            return log
        }

        var array = Debug.Log.localLogs[id, default: []]

        array.append(log)

        if array.count > Debug.Log.configuration.loggableLimit {
            array.removeFirst()
        }

        Debug.Log.localLogs[id] = array
        return log
    }
}
