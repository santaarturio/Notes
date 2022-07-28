import SwiftUI

struct NotesDetailsView: View {
  
  @ObservedObject var viewModel: NotesDetailsViewModel
  
  var body: some View {
    ScrollView {
      HStack {
        
        VStack(alignment: .leading) {
          Text(viewModel.title)
            .font(.title)
          
            Spacer(minLength: 16.0)
          
          Text(viewModel.text)
            .font(.title3)
        }.padding()
        
        Spacer()
      }
    }
  }
}

struct NotesDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    NotesDetailsView(
      viewModel: NotesDetailsViewModel(
        note: .init()
      )
    )
  }
}
