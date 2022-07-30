import XCTest
import Debug

final class DebugTests: XCTestCase {
    func testExample() {
        Debug.log("Hello, world!")
        Debug.log(.warning, "Careful!")
        Debug.log(.warning, in: .startup, "Careful!")
        Debug.log(.error, "You didn't listen!!")
        
        Log.info("nothing really going on")
        Log.info(in: .database, "saved data to disk")
        
        Log.debug(in: .database, "Missed cache hit")
        
        Log.warning(in: .database, "Missing data!", params: ["collection": "store"])
        
        Log.error(in: .database, "ALL DATA GONE!")
    }
}
