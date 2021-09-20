import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
  
  @Binding var isAnimating: Bool
  let style: UIActivityIndicatorView.Style
  
  func makeUIView(
    context: UIViewRepresentableContext<ActivityIndicator>
  ) -> UIActivityIndicatorView { UIActivityIndicatorView(style: style) }
  
  func updateUIView(
    _ uiView: UIActivityIndicatorView,
    context: UIViewRepresentableContext<ActivityIndicator>
  ) {
    isAnimating
      ? uiView.startAnimating()
      : uiView.stopAnimating()
  }
}

struct LoadingView: View {
  
  let title: String
  @Binding var isLoading: Bool
  
  var body: some View {
    VStack(spacing: 16) {
      Text(title)
      ActivityIndicator(isAnimating: $isLoading, style: .large)
    }
    .padding(EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16))
    .fixedSize(horizontal: true, vertical: true)
    .background(Color(Asset.Colors.panda.color))
    .foregroundColor(Color(Asset.Colors.zebra.color))
    .cornerRadius(20)
    .shadow(radius: 10)
  }
}

struct LoadingModifier: ViewModifier {
  let text: String
  @Binding var isLoading: Bool
  
  func body(content: Content) -> some View {
    ZStack {
      content
        .blur(radius: isLoading ? 1.5 : 0)
      LoadingView(title: text, isLoading: $isLoading)
        .opacity(isLoading ? 1 : 0)
        .animation(.easeOut(duration: 0.1))
    }
  }
}

extension View {
  func isLoading(
    _ isLoading: Binding<Bool>,
    text: String
  ) -> some View {
    self.modifier(LoadingModifier(text: text, isLoading: isLoading))
  }
}
