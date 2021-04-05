//  Created by Dominik Hauser on 05/04/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation

struct LatLongText: View {
  
  let coordinate: CLLocationCoordinate2D?
  
  var body: some View {
    if let coordinate = coordinate,
       abs(coordinate.latitude) > 0.001,
       abs(coordinate.longitude) > 0.001 {
      Text("latitude: \(coordinate.latitude)\nlongitude: \(coordinate.longitude)")
        .font(.footnote)
        .multilineTextAlignment(.center)
        .foregroundColor(Color(UIColor.secondaryLabel))
    } else {
      EmptyView()
    }
  }
}

struct LatLongText_Previews: PreviewProvider {
  static var previews: some View {
    LatLongText(coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 2))
  }
}
