//  Created by Dominik Hauser on 05.11.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import Foundation
import CoreLocation

struct PointOfRelevance: Codable, Identifiable, Hashable {
  var id: String {
    return String(format: "%.5lf,%.5lf", coordinate.latitude, coordinate.longitude)
  }
  let name: String
  let address: String
  let coordinate: Coordinate
  let timezone: TimeZone?

  var clLocation: CLLocation {
    return CLLocation(latitude: coordinate.latitude,
                      longitude: coordinate.longitude)
  }
}
