import Foundation

fileprivate let cachedFormatter = ISO8601DateFormatter()

extension ISO8601DateFormatter {
  static var cached: ISO8601DateFormatter { cachedFormatter }
}
