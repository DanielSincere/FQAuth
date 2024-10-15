import Foundation
import XCTest

func XCTAssertNearlyEqual(_ a: Date, _ b: Date, file: StaticString = #filePath, line: UInt = #line) {
  XCTAssertEqual(a.timeIntervalSinceReferenceDate,
                 b.timeIntervalSinceReferenceDate,
                 accuracy: 1,
                 file: file,
                 line: line)
}
