//  Created by Dominik Hauser on 29.12.25.
//  
//


import SwiftUI

struct LegalInfoView: View {
  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 20) {
        Text("Imprint:")
          .bold()
        Text("Responsible for this app is\nDominik Hauser\ndominik.hauser@dasdom.de")
          .multilineTextAlignment(.leading)
        Text("The information you put in is only stored on your device.")
        Spacer()
      }
      .padding()
      .navigationTitle("Legal")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  LegalInfoView()
}
