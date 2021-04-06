//  Created by Dominik Hauser on 06/04/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import CoreLocation
import UIKit

extension CLDeviceOrientation {
  init?(interfaceOrientation: UIInterfaceOrientation) {
    self.init(rawValue: Int32(interfaceOrientation.rawValue))
  }
}
