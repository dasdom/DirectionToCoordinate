//  Created by Dominik Hauser on 02/04/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import CoreLocation

class StubHeading: CLHeading {

  let magneticHeadingToReturn: CLLocationDirection
  
  init(magneticHeadingToReturn: CLLocationDirection) {
    self.magneticHeadingToReturn = magneticHeadingToReturn
    
    super.init()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  override var magneticHeading: CLLocationDirection {
    return magneticHeadingToReturn
  }
}
