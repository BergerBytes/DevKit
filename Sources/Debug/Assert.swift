import Foundation

extension Debug {
    public struct Assert {
        public static var configuration = Configuration()
        
        public struct Configuration {
            public let throwAssertionFailures: Bool
            
            public init(throwAssertionFailures: Bool = true) {
                self.throwAssertionFailures = throwAssertionFailures
            }
        }
    }
    
    public static func assert(
        _ assertion: () -> Bool,
        message: Any?,
        params: [String: Any?]? = nil,
        file: String     = #file,
        function: String = #function,
        line: Int        = #line
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
    
    public static func assert(
        _ assertion: Bool,
        message: Any?,
        params: [String: Any?]? = nil,
        file: String     = #file,
        function: String = #function,
        line: Int        = #line
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
    
    public static func assertionFailure(
        _ message: Any?,
        params: [String: Any?]? = nil,
        file: String     = #file,
        function: String = #function,
        line: Int        = #line
    ) {
        let log = Debug.log(
            level: .error,
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
