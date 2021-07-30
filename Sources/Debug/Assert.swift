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
    
    public static func assertionFailure(
        _ message: Any?,
        file: String     = #file,
        function: String = #function,
        line: Int        = #line
    ) {
        let log = Debug.log(
            message,
            level: .error,
            file: file,
            function: function,
            line: line
        )
                
        if Assert.configuration.throwAssertionFailures {
            Swift.assertionFailure(log)
        }
    }
}
