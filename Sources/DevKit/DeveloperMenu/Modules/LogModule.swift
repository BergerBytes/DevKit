//
//  SwiftUIView.swift
//  
//
//  Created by Michael Berger on 12/23/22.
//

import SwiftUI
import Collections

@available(iOS 15, *)
struct LogEntry: Identifiable {
    let id = UUID()
    
    let scope: Log.Scope
    let level: Log.Level
    let message: Any?
    let params: [String: Any?]?
    let file: String
    let function: String
    let line: Int
    
    let timestamp = Date.now
    let location: String
    
    internal init(scope: Log.Scope? = nil, level: Log.Level, message: Any? = nil, params: [String : Any?]? = nil, file: String, function: String, line: Int) {
        self.scope = scope ?? .noScope
        self.level = level
        self.message = message
        self.params = params
        self.file = file
        self.function = function
        self.line = line
        
        location = Log.formattedCallSite(file: file, function: function, line: line)
    }
}

@available(iOS 15, *)
public class LogModule: Module {
    public let id: String = "Logs"
    public let logLimitPerScope: UInt = 200
    
    private var logs = OrderedDictionary<Log.Scope, Deque<LogEntry>>()
    
    public required init() {
        Log.logModuleCallback = { log in
            self.logs[log.scope, default: .init(minimumCapacity: Int(self.logLimitPerScope))]
                .prepend(log)
            
            if (self.logs[log.scope]?.count ?? 0) >= self.logLimitPerScope {
                _ = self.logs[log.scope]?.popLast()
            }
        }
    }
    
    @MainActor
    @ViewBuilder
    public var content: some View {
        List {
            if !self.logs.isEmpty {
                NavigationLink {
                    LogScopeView(scope: nil, logs: self.logs.flatMap { $0.value }.sorted(by: { $0.timestamp > $1.timestamp }))
                        .navigationTitle("All")
                } label: {
                    HStack {
                        Text("All")
                        Spacer()
                        Text("\(self.logs.values.map(\.count).reduce(0, +))")
                    }
                }
            }
            
            ForEach(logs.keys, id: \.symbol) { log in
                NavigationLink {
                    LogScopeView(scope: log, logs: self.logs[log] ?? [])
                        .navigationTitle("\(String(log.symbol)) \(log.name)")
                } label: {
                    HStack {
                        Text("\(String(log.symbol)) \(log.name)")
                        
                        Spacer()
                        
                        if let errorCount = self.logs[log]?.filter { $0.level == .error }.count, errorCount != 0 {
                            Text("\(errorCount)")
                                .padding(8)
                                .background(.red, in: Capsule())
                        }
                        
                        if let warningCount = self.logs[log]?.filter { $0.level == .warning }.count, warningCount != 0 {
                            Text("\(warningCount)")
                                .padding(8)
                                .background(.orange, in: Capsule())
                        }
                        
                        Text("\(self.logs[log]?.count ?? 0)")
                    }
                }
            }
        }
        .font(.body.monospacedDigit())
    }
}

@available(iOS 15, *)
extension LogModule {
    struct LogScopeView: View {
        let scope: Log.Scope?
        let logs: [LogEntry]
        
        internal init(scope: Log.Scope?, logs: some RandomAccessCollection<LogEntry>) {
            self.scope = scope
            self.logs = Array(logs)
        }
        
        var body: some View {
            List {
                ForEach(logs) { log in
                    HStack {
                        if scope == nil, let scope = log.scope {
                            Text(String(scope.symbol))
                        }
                        Text(log.level.symbol)

                        VStack(alignment: .leading) {
                            if let message = log.message {
                                Text(String(describing: message))
                            }
                            Text(log.location)
                                .font(.caption2)
                                .opacity(0.7)
                        }
                        
                        if
                            let params: [String: Any?] = log.params,
                            let keys: [String] = params.keys.sorted(by: { $0.hashValue > $1.hashValue })
                        {
                            Spacer()
                            VStack(alignment: .trailing) {
                                if #available(iOS 16.0, *) {
                                    Grid {
                                        ForEach(keys, id: \.hashValue) { key in
                                            GridRow {
                                                Text(key + ": ")
                                                if let entry = params[key] {
                                                    Text(entry.map { String(describing: $0) } ?? "nil")
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    ForEach(keys, id: \.hashValue) { key in
                                        HStack {
                                            Text(key + ": ")
                                            if let entry = params[key], let value = entry {
                                                Text(String(describing: value))
                                            }
                                        }
                                    }
                                }
                            }
                            .font(.caption)
                        }
                    }
                }
            }
        }
    }
}

extension Log.Scope {
    public static var noScope = Log.Scope("-", name: "No Scope")
}

@available(iOS 15, *)
struct LogModuleView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

@available(iOS 15, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        LogModuleView()
    }
}
