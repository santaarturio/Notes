import SwiftUI

struct LoginScreen: View {
  
  @ObservedObject var viewModel: LoginViewModel
  @ObservedObject var keyboardResponder = KeyboardResponder()
  
  @State var isSignUpPresented = false
  
  var body: some View {
    VStack {
      LogoImage()
      Spacer()
      EmailTextField(text: $viewModel.email)
      Spacer().frame(height: 16)
      PasswordTextField(text: $viewModel.password)
      Spacer().frame(height: 64)
      SignInButton(action: { viewModel.signIn?() }, isEnabled: $viewModel.signIn.map { $0 != nil })
      Spacer().frame(height: 16)
      SignUpButton(action: { isSignUpPresented = true })
    }
    .isLoading($viewModel.isDownloading, text: L10n.App.Login.authorization)
    .sheet(isPresented: $isSignUpPresented) { viewModel.signUpView }
    .accentColor(Color(Asset.Colors.zebra.color))
    .padding(
      EdgeInsets(
        top: keyboardResponder.isKeyboardShown ? 16 : 104,
        leading: 32,
        bottom: 16,
        trailing: 32
      )
    )
    .animation(.easeOut(duration: 0.4), value: keyboardResponder.isKeyboardShown)
    .gesture(DragGesture().onChanged { _ in endEditing() })
  }
}

// MARK: - Subviews
private extension LoginScreen {
  
  // MARK: LogoImage
  struct LogoImage: View {
    
    var body: some View {
      Image(uiImage: Asset.Images.mainLogo.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxHeight: 160)
    }
  }
  
  // MARK: EmailTextField
  struct EmailTextField: View {
    @Binding var text: String
    
    var body: some View {
      TextField(
        L10n.App.Login.Placeholder.email,
        text: $text
      )
      .keyboardType(.emailAddress)
      .autocapitalization(.none)
      .padding([.leading, .trailing], 8)
      .frame(minHeight: 44)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.accentColor, lineWidth: 1)
      )
    }
  }
  
  // MARK: PasswordTextField
  struct PasswordTextField: View {
    @Binding var text: String
    
    var body: some View {
      SecureField(
        L10n.App.Login.Placeholder.password,
        text: $text
      )
      .padding([.leading, .trailing], 8)
      .frame(minHeight: 44)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.accentColor, lineWidth: 1)
      )
    }
  }
  
  // MARK: SignInButton
  struct SignInButton: View {
    let action: () -> Void
    @Binding var isEnabled: Bool
    
    var body: some View {
      Button(
        action: action,
        label: {
          Text(L10n.App.Login.signIn)
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundColor(isEnabled ? .accentColor : Color.gray)
            .font(.body)
        }
      )
      .disabled(!isEnabled)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(isEnabled ? .accentColor : Color.gray, lineWidth: 1)
      )
    }
  }
  
  // MARK: SignUpButton
  struct SignUpButton: View {
    let action: () -> Void
    
    var body: some View {
      Button(
        action: action,
        label: {
          Text(L10n.App.Login.signUp)
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundColor(.accentColor)
            .font(.body)
        }
      )
    }
  }
}

// MARK: - PreviewProvider
struct LoginScreen_Previews: PreviewProvider {
  static var previews: some View {
    LoginScreen(viewModel: .init(api: LoginAPI()))
  }
}
