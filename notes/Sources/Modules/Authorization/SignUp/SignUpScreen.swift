import SwiftUI

struct SignUpScreen: View {
  
  @ObservedObject var viewModel: SignUpViewModel
  @ObservedObject var keyboardResponder = KeyboardResponder()
  
  var body: some View {
    ZStack {
      VStack {
        
        Image(uiImage: Asset.Images.mainLogo.image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(idealHeight: 80, maxHeight: 160)
        
        Spacer()
        
        TextField(
          L10n.App.Login.Placeholder.name,
          text: $viewModel.name
        )
        .autocapitalization(.words)
        .padding([.leading, .trailing], 8)
        .frame(minHeight: 44)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.accentColor, lineWidth: 1)
        )
        
        Spacer()
          .frame(height: 16)
        
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
          action: { viewModel.signUp?() },
          label: {
            Text(L10n.App.Login.signUp)
              .frame(minWidth: UIScreen.width - 64, minHeight: 44)
              .foregroundColor(viewModel.signUp == nil ? Color.gray : .accentColor)
              .font(.body)
          }
        )
        .disabled(viewModel.signUp == nil)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(viewModel.signUp == nil ? Color.gray : .accentColor, lineWidth: 1)
        )
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
      .animation(.easeOut(duration: 0.3), value: keyboardResponder.isKeyboardShown)
      .gesture(DragGesture().onChanged { _ in endEditing() })
      
      VStack {
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
  }
}

struct SignUpScreen_Previews: PreviewProvider {
  static var previews: some View {
    SignUpScreen(viewModel: SignUpViewModel(api: LoginAPI()))
  }
}
