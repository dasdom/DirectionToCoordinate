//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI

@main
struct DirectionToCoordinateApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(LocationProvider())
    }
  }
}
