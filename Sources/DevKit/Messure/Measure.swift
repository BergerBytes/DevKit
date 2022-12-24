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
import QuartzCore

public enum Measure {
    public static var records = [String: Record]()

    @inlinable
    @discardableResult
    public static func this(
        name: String? = nil,
        _ invocation: () -> Void,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> TimeInterval {
        let startTime = CACurrentMediaTime()
        invocation()
        let endTime = CACurrentMediaTime()

        let key = name ?? "\(Log.fileName(in: file)).\(function) [\(line)]"
        let time = endTime - startTime

        if let record = records[key] {
            record.add(time: time)
        } else {
            records[key] = .init(key: key, time: time)
        }

        return time
    }
}

public extension Measure {
    class Record: CustomDebugStringConvertible {
        public let key: String
        public var mostRecentTime: TimeInterval = 0
        public var averageTime: TimeInterval {
            sum / TimeInterval(count)
        }

        private var sum: TimeInterval = 0
        private var count: Int = 0

        public private(set) var minTime: TimeInterval = .greatestFiniteMagnitude
        public private(set) var maxTime: TimeInterval = .leastNonzeroMagnitude

        public let percentiles = [
            99: CKMS(percentile: 0.99, reservoirSize: 50),
            95: CKMS(percentile: 0.95, reservoirSize: 50),
            90: CKMS(percentile: 0.90, reservoirSize: 50),

            1: CKMS(percentile: 0.01, reservoirSize: 50),
            5: CKMS(percentile: 0.05, reservoirSize: 50),
            10: CKMS(percentile: 0.10, reservoirSize: 50),
        ]

        public init(key: String, time: TimeInterval) {
            self.key = key
            add(time: time)
        }

        public func add(time: TimeInterval) {
            mostRecentTime = time

            sum += time
            count += 1

            if time < minTime {
                minTime = time
            }

            if time > maxTime {
                maxTime = time
            }

            percentiles.values.forEach {
                $0.add(time)
            }
        }

        public var debugDescription: String {
            """
            Measure Record for: \(key)
            mostRecentTime:     \(mostRecentTime)
            averageTime:        \(averageTime)
            """
        }
    }
}

public extension Measure {
    class CKMS {
        public let percentile: Double

        // The reservoir of values
        private lazy var values = [TimeInterval]()

        // The size of the reservoir
        private let reservoirSize: Int

        // The number of values that have been processed
        private var count: TimeInterval = 0.0

        // The current estimate of the 99th percentile
        public private(set) var estimate: TimeInterval = 0.0

        // Initialize the CKMS algorithm with the desired reservoir size
        init(percentile: Double, reservoirSize: Int) {
            self.percentile = percentile
            self.reservoirSize = reservoirSize
        }

        // Add a new value to the CKMS algorithm
        func add(_ value: TimeInterval) {
            count += 1
            if values.count < reservoirSize {
                // If the reservoir is not full, add the value to the reservoir
                values.append(value)
                values.sort()
                estimate = values[Int(Double(values.count) * percentile)]
            } else {
                // If the reservoir is full, only add the value to the reservoir if it is higher than the 99th percentile
                if value > estimate {
                    values.append(value)
                    values.sort()
                    values.removeFirst()
                    estimate = values[Int(Double(values.count) * percentile)]
                }
            }
        }
    }
}

public extension Log.Scope {
    static var measure: Log.Scope { Log.Scope("📐", name: "Measure") }
}
