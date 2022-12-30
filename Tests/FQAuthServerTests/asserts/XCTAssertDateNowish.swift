import XCTest
import Foundation

func XCAssertDateNowish(_ a: Date, file: StaticString = #filePath, line: UInt = #line) {
  XCTAssertEqual(a.timeIntervalSinceReferenceDate,
                 Date().timeIntervalSinceReferenceDate,
                 accuracy: 3,
                 file: file,
                 line: line)
}
