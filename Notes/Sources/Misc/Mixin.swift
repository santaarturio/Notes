import Foundation

// MARK: - Mixin
open class Mixin<Base> {
  
  private let constructor: () -> Base
  
  public var base: Base {
    constructor()
  }
  
  public init(constructor: @escaping () -> Base) {
    self.constructor = constructor
  }
  
  public init(base: Base) {
    constructor = { base }
  }
}

// MARK: - NSMixin
open class NSMixin<Base>: NSObject {
  
  public let base: Base
  
  public init(constructor: () -> Base) {
    base = constructor()
  }
}
