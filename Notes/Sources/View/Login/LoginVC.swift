import UIKit
import Combine

// MARK: - UIViewController + Bindable
final class LoginVC: UIViewController, Bindable {
  
  var viewModel: LoginViewModel!
  private var cancellables: Set<AnyCancellable> = []
  
  private lazy var logoImageView = UIImageView()
  private lazy var spacer = UIView()
  
  private lazy var emailTextField = UITextField()
  private lazy var passwordTextField = UITextField()
  
  private lazy var signUpButton = ANButton()
  private lazy var signInButton = ANButton()
  
  private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
  private lazy var stackView = UIStackView()
  
  private lazy var stackTop = stackView
    .topAnchor
    .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 104)
  private lazy var stackBottom = stackView
    .bottomAnchor
    .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
  
  private var textFields: [UITextField] {
    [emailTextField, passwordTextField]
  }
  
  private var buttons: [UIButton] {
    [signUpButton, signInButton]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupObserving()
  }
  
  func bind(_ viewModel: LoginViewModel) {
    self.viewModel = viewModel
    
    signUpButton
      .publisher(for: .touchUpInside)
      .map { _ in () }
      .subscribe(viewModel.signUpSubject)
      .store(in: &cancellables)
    
    signInButton
      .publisher(for: .touchUpInside)
      .map { _ in () }
      .subscribe(viewModel.signInSubject)
      .store(in: &cancellables)
    
    emailTextField
      .publisher(for: .editingChanged)
      .compactMap(\.text)
      .subscribe(viewModel.emailSubject)
      .store(in: &cancellables)
    
    passwordTextField
      .publisher(for: .editingChanged)
      .compactMap(\.text)
      .subscribe(viewModel.passwordSubject)
      .store(in: &cancellables)
    
    viewModel
      .canGoSubject
      .sink(receiveValue: weakify(LoginVC.handleIsEnabled, object: self))
      .store(in: &cancellables)
    
    viewModel
      .isDownloadingSubject
      .sink(receiveValue: weakify(LoginVC.handleIsDownloading, object: self))
      .store(in: &cancellables)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    view.endEditing(true)
  }
}

// MARK: - ViewCode
extension LoginVC: ViewCode {
  
  func setupViewHierarchy() {
    [logoImageView, spacer, emailTextField, passwordTextField, signInButton, signUpButton]
      .forEach(stackView.addArrangedSubview)
    [stackView, activityIndicator]
      .forEach(view.addSubview)
  }
  
  func setupConstraints() {
    
    logoImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 160).isActive = true
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackTop,
      stackBottom,
      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64)
    ])
    
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    
    (textFields + buttons as [UIView])
      .forEach { view in
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
      }
  }
  
  func setupAdditionalConfiguration() {
    view.backgroundColor = Asset.Colors.panda.color
    
    logoImageView.contentMode = .scaleAspectFit
    logoImageView.image = Asset.Images.mainLogo.image
    logoImageView.isAccessibilityElement = true
    logoImageView.accessibilityLabel = L10n.App.General.logoAccessibilityLabel
    logoImageView.accessibilityTraits = [.image]
    
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.setCustomSpacing(64, after: passwordTextField)
    
    textFields
      .forEach { textField in
        textField.setLeftPadding(8)
        textField.clearButtonMode = .always
        textField.layer.borderWidth = 1
        textField.layer.borderColor = Asset.Colors.zebra.color.cgColor
        textField.textColor = Asset.Colors.zebra.color
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
      }
    
    (textFields + buttons as [UIView])
      .forEach { view in
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
      }
    
    buttons
      .forEach { button in
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.setTitleColor(Asset.Colors.zebra.color, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
      }
    
    emailTextField.autocapitalizationType = .none
    emailTextField.keyboardType = .emailAddress
    emailTextField.attributedPlaceholder = NSAttributedString(
      string: L10n.App.Login.Placeholder.email,
      attributes: [.foregroundColor: UIColor.gray]
    )
    
    passwordTextField.isSecureTextEntry = true
    passwordTextField.attributedPlaceholder = NSAttributedString(
      string: L10n.App.Login.Placeholder.password,
      attributes: [.foregroundColor: UIColor.gray]
    )
    
    signUpButton.setTitle(L10n.App.Login.signUp, for: .normal)
    signInButton.setTitle(L10n.App.Login.signIn, for: .normal)
  }
  
  private func handleIsEnabled(_ isEnabled: Bool) {
    buttons
      .forEach {
        $0.isEnabled = isEnabled
        $0.layer.borderColor = isEnabled
          ? Asset.Colors.zebra.color.cgColor
          : UIColor.gray.cgColor
      }
  }
  
  private func handleIsDownloading(_ isDownloading: Bool) {
    isDownloading
      ? activityIndicator.startAnimating()
      : activityIndicator.stopAnimating()
  }
  
  private func setupObserving() {
    textFields
      .forEach { $0.delegate = self }
    
    let signUp = signUpButton
      .publisher(for: .touchUpInside)
    
    let signIn = signInButton
      .publisher(for: .touchUpInside)
    
    signUp.merge(with: signIn)
      .sink(receiveValue: { [weak self] _ in self?.view.endEditing(true) })
      .store(in: &cancellables)
    
    let willShow = NotificationCenter
      .default
      .publisher(for: UIResponder.keyboardWillShowNotification)
      .map { notification -> CGRect in
        guard let keyboard = notification
                .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return .zero }
        return keyboard.cgRectValue }
    
    let willHide = NotificationCenter
      .default
      .publisher(for: UIResponder.keyboardWillHideNotification)
      .map { _ in CGRect.zero }
    
    willShow.merge(with: willHide)
      .sink(receiveValue: weakify(LoginVC.setupKeyboardFrameObserving, object: self))
      .store(in: &cancellables)
  }
  
  private func setupKeyboardFrameObserving(rect: CGRect) {
    
    stackTop.constant = rect.height != .zero
      ? 16
      : 104
    
    stackBottom.constant = rect.height != .zero
      ? -rect.height
      : -16
    
    UIView
      .animate(
        withDuration: 0.5,
        animations: weakify(UIView.layoutIfNeeded, object: view)
      )
  }
}

// MARK: - UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    guard textFields.last !== textField else {
      textField.resignFirstResponder()
      return true
    }
    
    _ = textFields
      .firstIndex(of: textField)
      .map { textFields[$0 + 1].becomeFirstResponder() }
    
    return true
  }
}
