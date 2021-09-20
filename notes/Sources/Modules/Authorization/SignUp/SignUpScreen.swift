import SwiftUI

struct SignUpScreen: View {
  
  @ObservedObject var viewModel: SignUpViewModel
  @ObservedObject var keyboardResponder = KeyboardResponder()
  
  var body: some View {
    VStack {
      LogoImage()
      Spacer()
      NameTextField(text: $viewModel.name)
      Spacer().frame(height: 16)
      EmailTextField(text: $viewModel.email)
      Spacer().frame(height: 16)
      PasswordTextField(text: $viewModel.password)
      Spacer().frame(height: 64)
      SignUpButton(action: { viewModel.signUp?() }, isEnabled: $viewModel.signUp.map { $0 != nil })
    }
    .isLoading($viewModel.isDownloading, text: L10n.App.Login.authorization)
    .accentColor(Color(Asset.Colors.zebra.color))
    .padding(
      EdgeInsets(
        top: keyboardResponder.isKeyboardShown ? 16 : 104,
        leading: 32,
        bottom: 16,
        trailing: 32
      )
    )
    .animation(.easeOut(duration: 0.3), value: keyboardResponder.isKeyboardShown)
    .gesture(DragGesture().onChanged { _ in endEditing() })
  }
}

// MARK: - Subviews
private extension SignUpScreen {
  
  // MARK: LogoImage
  struct LogoImage: View {
    
    var body: some View {
      Image(uiImage: Asset.Images.mainLogo.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxHeight: 160)
    }
  }
  
  // MARK: NameTextField
  struct NameTextField: View {
    @Binding var text: String
    
    var body: some View {
      TextField(
        L10n.App.Login.Placeholder.name,
        text: $text
      )
      .autocapitalization(.words)
      .padding([.leading, .trailing], 8)
      .frame(minHeight: 44)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.accentColor, lineWidth: 1)
      )
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
  
  // MARK: SignUpButton
  struct SignUpButton: View {
    let action: () -> Void
    @Binding var isEnabled: Bool
    
    var body: some View {
      Button(
        action: action,
        label: {
          Text(L10n.App.Login.signUp)
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
}


struct SignUpScreen_Previews: PreviewProvider {
  static var previews: some View {
    SignUpScreen(viewModel: SignUpViewModel(api: LoginAPI()))
  }
}
