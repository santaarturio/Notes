
protocol Bindable {
  
  associatedtype ViewModel
  var viewModel: ViewModel! { get set }
  func bind(_ viewModel: ViewModel)
}
