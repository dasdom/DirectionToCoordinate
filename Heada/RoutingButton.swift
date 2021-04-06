//  Created by Dominik Hauser on 06/04/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import MapKit

struct RoutingButton: View {
  
  @ObservedObject var locationProvider: LocationProvider
  
  var body: some View {
    if locationProvider.distance > 0 {
      Button(action: openMapWithDirections) {
        Image(systemName: "arrow.triangle.turn.up.right.diamond")
      }
      .font(.title)
    }
  }
  
  private func openMapWithDirections() {
    if let coordinate = locationProvider.addressLocation?.coordinate,
       let address = locationProvider.address {
      let place = MKPlacemark(coordinate: coordinate)
      let destination = MKMapItem(placemark: place)
      destination.name = address
      let options = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDefault]
      MKMapItem.openMaps(with: [destination], launchOptions: options)
    }
  }
}

struct RoutingButton_Previews: PreviewProvider {
  static var previews: some View {
    RoutingButton(locationProvider: LocationProvider())
  }
}
