//  Created by Dominik Hauser on 01/04/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit

class Announcer {
  var angleOfLastAnnouncement: Int = 180
  
  func announce(angleInt: Int, address: String, distance: Double) {
    if angleInt % 10 == 0 && angleInt != angleOfLastAnnouncement {
      let announcement: String
      if angleInt < 0 {
        announcement = "\(abs(angleInt)) degrees to the left"
      } else if angleInt > 0 {
        announcement = "\(abs(angleInt)) degrees to the right"
      } else {
        announcement = "\(address) is \(Int(distance/1000)) km straight ahead"
      }
      angleOfLastAnnouncement = angleInt
      UIAccessibility.post(notification: .announcement, argument: announcement)
    }
  }
}
