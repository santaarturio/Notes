import SwiftUI

struct LoginScreen: View {
  
  @ObservedObject var viewModel: LoginViewModel
  @ObservedObject var keyboardResponder = KeyboardResponder()
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        VStack {
          
          Image(uiImage: Asset.Images.mainLogo.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxHeight: 160)
          
          Spacer()
          
          TextField(
            L10n.App.Login.Placeholder.email,
            text: $viewModel.email
          )
          .keyboardType(.emailAddress)
          .autocapitalization(.none)
          .padding([.leading, .trailing], 8)
          .frame(minHeight: 44)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.accentColor, lineWidth: 1)
          )
          
          Spacer()
            .frame(height: 16)
          
          SecureField(
            L10n.App.Login.Placeholder.password,
            text: $viewModel.password
          )
          .padding([.leading, .trailing], 8)
          .frame(minHeight: 44)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.accentColor, lineWidth: 1)
          )
          
          Spacer()
            .frame(height: 32)
          
          makeButton(
            title: L10n.App.Login.signIn,
            action: { viewModel.login?(.signIn) })
          
          Spacer()
            .frame(height: 16)
          
          makeButton(
            title: L10n.App.Login.signUp,
            action: { viewModel.login?(.signUp) })
        }
        .accentColor(Color(Asset.Colors.zebra.color))
        .padding(
          EdgeInsets(
            top: keyboardResponder.isKeyboardShown ? 52 : 148,
            leading: 32,
            bottom: keyboardResponder.isKeyboardShown ? 16 : 60,
            trailing: 32
          )
        )
        .padding(.bottom, keyboardResponder.keyboardHeight)
        .blur(radius: viewModel.isDownloading ? 1.5 : 0)
        .animation(.easeOut(duration: 0.3), value: keyboardResponder.isKeyboardShown)
        .gesture(DragGesture().onChanged { _ in endEditing() })
        
        VStack {
          Text(L10n.App.Login.authorization)
          ActivityIndicator(isAnimating: $viewModel.isDownloading, style: .large)
        }
        .frame(width: geometry.size.width / 2,
               height: geometry.size.height / 5)
        .background(Color(Asset.Colors.panda.color))
        .foregroundColor(Color(Asset.Colors.zebra.color))
        .cornerRadius(20)
        .shadow(radius: 10)
        .opacity(viewModel.isDownloading ? 1 : 0)
        .animation(.easeOut(duration: 0.1), value: viewModel.isDownloading)
      }
      .animation(.easeOut(duration: 0.3))
    }
  }
  
  private func makeButton(
    title: String,
    action: @escaping () -> Void
  ) -> some View {
    Button(
      action: action,
      label: {
        Text(title)
          .frame(minWidth: UIScreen.width - 64, minHeight: 44)
          .foregroundColor(buttonColor)
          .font(.body)
      }
    )
    .disabled(isButtonDisabled)
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .stroke(buttonColor, lineWidth: 1)
    )
  }
  
  private var isButtonDisabled: Bool {
    viewModel.login == nil
  }
  
  private var buttonColor: Color {
    isButtonDisabled ? .gray : .accentColor
  }
  
  private func endEditing() {
    UIApplication
      .shared
      .sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil, from: nil, for: nil
      )
  }
}

struct LoginScreen_Previews: PreviewProvider {
  static var previews: some View {
    LoginScreen(viewModel: .init(api: .init(), navigator: .init(base: nil)))
  }
}
