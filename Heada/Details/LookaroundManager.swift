//  Created by Dominik Hauser on 11.01.26.
//  Copyright © 2026 dasdom. All rights reserved.
//
// Source: https://www.createwithswift.com/implementing-look-around-with-mapkit-in-swiftui/


import SwiftUI
import MapKit

@Observable
class LookAroundManager {

  var lookAroundScene: MKLookAroundScene?

  func loadPreview(coordinate: CLLocationCoordinate2D) async {
    Task {
      let request = MKLookAroundSceneRequest(coordinate: coordinate)
      do {
        lookAroundScene = try await request.scene
      } catch (let error) {
        print(error)
      }
    }
  }

}
