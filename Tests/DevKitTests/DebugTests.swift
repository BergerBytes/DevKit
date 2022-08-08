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

import DevKit
import XCTest

final class DebugTests: XCTestCase {
    func testExample() {
        Log.custom(.warning, "Careful!")
        Log.custom(.warning, in: .startup, "Careful!")
        Log.custom(.error, "You didn't listen!!")

        Log.info("nothing really going on")
        Log.info(in: .database, "saved data to disk")

        Log.debug(in: .database, "Missed cache hit")

        Log.warning(in: .database, "Missing data!", params: ["collection": "store"])

        Log.error(in: .database, "ALL DATA GONE!")
    }
}
