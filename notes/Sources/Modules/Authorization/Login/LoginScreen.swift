import SwiftUI

struct LoginScreen: View {
  
  @ObservedObject var viewModel: LoginViewModel
  @ObservedObject var keyboardResponder = KeyboardResponder()
  
  @State var isSignUpPresented = false
  
  var body: some View {
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
          .frame(height: 64)
        
        Button(
          action: { viewModel.signIn?() },
          label: {
            Text(L10n.App.Login.signIn)
              .frame(minWidth: UIScreen.width - 64, minHeight: 44)
              .foregroundColor(viewModel.signIn == nil ? Color.gray : .accentColor)
              .font(.body)
          }
        )
        .disabled(viewModel.signIn == nil)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(viewModel.signIn == nil ? Color.gray : .accentColor, lineWidth: 1)
        )
        
        Spacer()
          .frame(height: 16)
        
        Button(
          action: { isSignUpPresented = true },
          label: {
            Text(L10n.App.Login.signUp)
              .frame(minWidth: UIScreen.width - 64, minHeight: 44)
              .foregroundColor(.accentColor)
              .font(.body)
          }
        )
        .sheet(isPresented: $isSignUpPresented) { viewModel.signUpView }
      }
      .accentColor(Color(Asset.Colors.zebra.color))
      .padding(
        EdgeInsets(
          top: keyboardResponder.isKeyboardShown ? 16 : 104,
          leading: 32,
          bottom: 16,
          trailing: 32
        )
      )
      .blur(radius: viewModel.isDownloading ? 1.5 : 0)
      .animation(.easeOut(duration: 0.4), value: keyboardResponder.isKeyboardShown)
      .gesture(DragGesture().onChanged { _ in endEditing() })
      
      LazyVStack {
        Text(L10n.App.Login.authorization)
        ActivityIndicator(isAnimating: $viewModel.isDownloading, style: .large)
      }
      .frame(width: UIScreen.width / 2,
             height: UIScreen.height / 5)
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

struct LoginScreen_Previews: PreviewProvider {
  static var previews: some View {
    LoginScreen(viewModel: .init(api: LoginAPI()))
  }
}
