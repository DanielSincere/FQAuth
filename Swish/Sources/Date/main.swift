import Sh
import Foundation

let timeInterval = try sh(TimeInterval.self, "date +%s")
let date = Date(timeIntervalSince1970: timeInterval)
print("The date is \(date).")