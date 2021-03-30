//  Created by Dominik Hauser on 30/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
  let coordinate: CLLocationCoordinate2D
  
  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
  }
}
