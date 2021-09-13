import UIKit
import Combine

// MARK: - UIViewController + Bindable
final class LoginVC: UIViewController, Bindable {
  
  var viewModel: LoginViewModel!
  private var cancellables: Set<AnyCancellable> = []
  
  private lazy var backgroundImageView = UIImageView()
  private lazy var logoImageView = UIImageView()
  private lazy var spacer = UIView()
  
  private lazy var nameTextField = UITextField()
  private lazy var emailTextField = UITextField()
  private lazy var passwordTextField = UITextField()
  
  private lazy var signUpButton = ANButton()
  private lazy var signInButton = ANButton()
  private lazy var goButton = ANButton()
  
  private lazy var stackView = UIStackView()
  private lazy var stackBottom = stackView.bottomAnchor
    .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
  
  private var backButton: UIBarButtonItem!
  
  private var textFields: [UITextField] {
    [nameTextField, emailTextField, passwordTextField]
  }
  
  private var buttons: [UIButton] {
    [signUpButton, signInButton, goButton]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupObserving()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.navigationBar.isTranslucent = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    navigationController?.navigationBar.shadowImage = nil
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
    
    goButton
      .publisher(for: .touchUpInside)
      .map { _ in () }
      .subscribe(viewModel.goSubject)
      .store(in: &cancellables)
    
    goButton
      .publisher(for: .touchUpInside)
      .sink(receiveValue: { [weak self] _ in self?.view.endEditing(true) })
      .store(in: &cancellables)
    
    nameTextField
      .publisher(for: .allEditingEvents)
      .compactMap(\.text)
      .subscribe(viewModel.nameSubject)
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
      .stateSubject
      .sink(receiveValue: weakify(LoginVC.handleState, object: self))
      .store(in: &cancellables)
  }
  
  private func handleState(_ state: LoginViewModel.State) {
    
    [emailTextField, passwordTextField, goButton]
      .forEach { $0.isHidden = state.isInitial }
    [signUpButton, signInButton]
      .forEach { $0.isHidden = !state.isInitial }
    
    switch state {
    case .initial:
      nameTextField.isHidden = true
    case .signUp:
      nameTextField.isHidden = false
    case let .go(isEnabled):
      goButton.isEnabled = isEnabled
    default: break
    }
    
    navigationItem
      .setLeftBarButton(
        state.isInitial ? nil : backButton,
        animated: true
      )
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    view.endEditing(true)
  }
}

// MARK: - ViewCode
extension LoginVC: ViewCode {
  
  func setupViewHierarchy() {
    [logoImageView, spacer, nameTextField, emailTextField, passwordTextField, goButton, signUpButton, signInButton]
      .forEach(stackView.addArrangedSubview)
    [backgroundImageView, stackView]
      .forEach(view.addSubview)
  }
  
  func setupConstraints() {
    backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
      backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
      backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    logoImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64),
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
      stackBottom
    ])
    
    textFields
      .forEach { textField in
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
      }
    
    buttons
      .forEach { button in
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
      }
  }
  
  func setupAdditionalConfiguration() {
    view.backgroundColor = Asset.Colors.panda.color
    
    backgroundImageView.contentMode = .scaleAspectFill
    backgroundImageView.image = Asset.Images.mainBackground.image
    
    logoImageView.contentMode = .scaleAspectFit
    logoImageView.image = Asset.Images.mainLogo.image
    
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.setCustomSpacing(8, after: logoImageView)
    stackView.setCustomSpacing(0, after: spacer)
    stackView.setCustomSpacing(64, after: passwordTextField)
    
    textFields
      .forEach { textField in
        textField.setLeftPadding(8)
        textField.setRightPadding(8)
      }
    
    (textFields + buttons as [UIView])
      .forEach { textField in
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
      }
    
    (textFields + [goButton] as [UIView])
      .forEach { $0.isHidden = true }
    
    nameTextField.placeholder = L10n.App.Login.Placeholder.name
    nameTextField.autocapitalizationType = .words
    nameTextField.autocorrectionType = .no
    
    emailTextField.placeholder = L10n.App.Login.Placeholder.email
    emailTextField.autocapitalizationType = .none
    emailTextField.keyboardType = .emailAddress
    
    passwordTextField.placeholder = L10n.App.Login.Placeholder.password
    passwordTextField.isSecureTextEntry = true
    
    signUpButton.setTitle(L10n.App.Login.signUp, for: .normal)
    signInButton.setTitle(L10n.App.Login.signIn, for: .normal)
    
    goButton.setTitleColor(.lightText, for: .disabled)
    goButton.setTitle(L10n.App.Login.fillAllFields, for: .disabled)
    goButton.setTitleColor(.white, for: .normal)
    goButton.setTitle(L10n.App.Login.go, for: .normal)
    goButton.isEnabled = false
    
    setupBackButton()
  }
  
  private func setupObserving() {
    textFields
      .forEach { $0.delegate = self }
    
    let willShow = NotificationCenter
      .default
      .publisher(for: UIResponder.keyboardWillShowNotification)
      .map { notification -> CGRect in
        guard
          let keyboard = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
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

// MARK: - Setup Back Button
private extension LoginVC {
  
  func setupBackButton() {
    backButton = UIBarButtonItem(
      image: Asset.Images.backButton.image
        .resizedImage(size: .init(width: 50, height: 50)),
      style: .plain,
      target: self,
      action: #selector(backButtonTapped)
    )
  }
  
  @objc func backButtonTapped(_ sender: UIBarButtonItem) {
    viewModel.backSubject.send()
    view.endEditing(true)
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

// MARK: - Convenience
private extension LoginViewModel.State {
  
  var isInitial: Bool {
    guard case .initial = self else { return false }
    return true
  }
  
  var isSignUp: Bool {
    guard case .signUp = self else { return false }
    return true
  }
  
  var isSignIn: Bool {
    guard case .signIn = self else { return false }
    return true
  }
  
  var isGo: Bool {
    guard case .go = self else { return false }
    return true
  }
}
