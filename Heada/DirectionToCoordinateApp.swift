//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI

@main
struct DirectionToCoordinateApp: App {
  @StateObject var locationProvider = LocationProvider()
  var body: some Scene {
    WindowGroup {
      HeadingsListView()
        .environmentObject(locationProvider)
    }
  }
}
