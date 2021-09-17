import UIKit
import Combine

extension UIControl: CombineCompatible { }

public extension UIControl {
  
  final class Subscription<SubscriberType: Subscriber, Control: UIControl>: Combine.Subscription
  where SubscriberType.Input == Control {
    
    private var subscriber: SubscriberType?
    private let control: Control
    
    public init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
      self.subscriber = subscriber
      self.control = control
      control.addTarget(self, action: #selector(eventHandler), for: event)
    }
    
    public func request(_ demand: Subscribers.Demand) {
      // We do nothing here as we only want to send events when they occur.
      // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }
    
    public func cancel() {
      subscriber = nil
    }
    
    @objc private func eventHandler() {
      _ = subscriber?.receive(control)
    }
  }
  
  struct Publisher<Control: UIControl>: Combine.Publisher {
    
    public typealias Output = Control
    public typealias Failure = Never
    
    let control: Control
    let controlEvents: UIControl.Event
    
    public init(control: Control, events: UIControl.Event) {
      self.control = control
      self.controlEvents = events
    }
    
    public func receive<S>(subscriber: S) where
      S : Subscriber,
      S.Failure == Publisher.Failure,
      S.Input == Publisher.Output
    {
      let subscription = UIControl.Subscription(
        subscriber: subscriber,
        control: control,
        event: controlEvents)
      subscriber.receive(subscription: subscription)
    }
  }
}

public extension CombineCompatible where Self: UIControl {
  func publisher(for events: UIControl.Event) -> UIControl.Publisher<Self> {
    .init(control: self, events: events)
  }
}
