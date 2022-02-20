//  Created by Dominik Hauser on 05.11.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import Foundation
import CoreLocation

struct PointOfRelevance: Codable {
  let name: String
  let address: String
  let coordinate: Coordinate

  var clLocation: CLLocation {
    return CLLocation(latitude: coordinate.latitude,
                      longitude: coordinate.longitude)
  }
}
