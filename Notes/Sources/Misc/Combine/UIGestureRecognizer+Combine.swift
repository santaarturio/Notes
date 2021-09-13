import UIKit
import Combine

extension UIGestureRecognizer: CombineCompatible { }

public extension UIGestureRecognizer {
  
  class Subscription<Subscriber: Combine.Subscriber, Input: UIGestureRecognizer>: Combine.Subscription
  where Subscriber.Input == Input,
        Subscriber.Failure == Never
  {
    
    private var subscriber: Subscriber?
    private var recognizer: Input
    private var view: UIView
    
    init(subscriber: Subscriber, view: UIView, recognizer: Input) {
      self.subscriber = subscriber
      self.view = view
      self.recognizer = recognizer
      
      configure(recognizer)
    }
    
    private func configure(_ input: Input) {
      input.addTarget(self, action: #selector(handler))
      view.addGestureRecognizer(input)
    }
    
    public func request(_ demand: Subscribers.Demand) { }
    
    public func cancel() {
      subscriber = nil
    }
    
    @objc
    private func handler() {
      _ = subscriber?.receive(recognizer)
    }
  }
  
  struct Publisher<Output: UIGestureRecognizer>: Combine.Publisher {
    
    public typealias Output = Output
    public typealias Failure = Never
    
    private let view: UIView
    private let recognizer: Output
    
    init(view: UIView, recognizer: Output) {
      self.view = view
      self.recognizer = recognizer
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber,
          Self.Failure == S.Failure,
          Self.Output == S.Input
    {
      let subscription = UIGestureRecognizer.Subscription(
        subscriber: subscriber,
        view: view,
        recognizer: recognizer
      )
      subscriber.receive(subscription: subscription)
    }
  }
}

public extension CombineCompatible where Self: UIGestureRecognizer {
  func publisher(for view: UIView) -> UIGestureRecognizer.Publisher<Self> {
    .init(view: view, recognizer: self)
  }
}
