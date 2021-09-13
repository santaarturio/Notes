import UIKit

protocol FactoryProtocol {
  func makeLoginVC() -> UIViewController
  func makeNotesVC() -> UIViewController
}
