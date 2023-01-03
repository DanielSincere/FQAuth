import XCTest
import Foundation

func XCTAssertNearlyNow(_ a: Date, file: StaticString = #filePath, line: UInt = #line) {
  XCTAssertNearlyEqual(a,
                       Date(),
                       file: file,
                       line: line)
}
