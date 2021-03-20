//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import CoreLocation

func deg2rad(_ number: Double) -> Double {
  return number * .pi / 180
}

func rad2deg(_ number: Double) -> Double {
  return number * 180 / .pi
}

extension CLLocationCoordinate2D {  
  
  func bearing(to coordinate: CLLocationCoordinate2D) -> Double {
    
    let lat1 = deg2rad(latitude)
    let long1 = deg2rad(longitude)
    
    let lat2 = deg2rad(coordinate.latitude)
    let long2 = deg2rad(coordinate.longitude)
    
    let dLon = long2 - long1
    
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radiansBearing = atan2(y, x)
    
    return (rad2deg(radiansBearing) + 360).truncatingRemainder(dividingBy: 360)
  }
}
