
public func weakify<Value: AnyObject, Result>(
  _ function: @escaping (Value) -> () -> Result,
  object: Value
)
-> () -> Result? {
  { [weak object] in
    object.map { function($0)() }
  }
}

public func weakify<Value: AnyObject, Arguments, Result>(
  _ function: @escaping (Value) -> (Arguments) -> Result,
  object: Value,
  default value: Result
)
-> (Arguments) -> Result {
  { [weak object] arguments in
    object.map { function($0)(arguments) } ?? value
  }
}

public func weakify<Value: AnyObject, Arguments, Result>(
  _ function: @escaping (Value) -> (Arguments) throws -> Result,
  object: Value,
  default value: Result
)
-> (Arguments) throws -> Result {
  { [weak object] arguments in
    try object.map { try function($0)(arguments) } ?? value
  }
}

public func weakify<Value: AnyObject, Arguments, Result>(
  _ function: @escaping (Value) -> (Arguments) -> () -> Result,
  object: Value,
  arguments: Arguments,
  default value: Result
)
-> () -> Result {
  { [weak object] in
    object.map { function($0)(arguments) }?() ?? value
  }
}

public func weakify<Value: AnyObject, Arguments>(
  _ function: @escaping (Value) -> (Arguments) -> Void,
  object: Value
)
-> (Arguments) -> Void {
  weakify(function, object: object, default: ())
}

public func weakify<Value: AnyObject>(
  _ function: @escaping (Value) -> () -> Void,
  object: Value
)
-> () -> Void {
  { [weak object] in
    object.map { function($0)() }
  }
}
