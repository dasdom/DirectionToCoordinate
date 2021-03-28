//  Created by Dominik Hauser on 14/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import CoreLocation

enum LocationProviderError: Error {
  case noLocation
}

class LocationProvider: NSObject, ObservableObject {
  
  private let locationManager: CLLocationManager
  @Published var location: CLLocation?
  @Published var heading: CLHeading?
  
  override init() {
    
    locationManager = CLLocationManager()
    
    super.init()
    
    locationManager.requestWhenInUseAuthorization()
    locationManager.delegate = self
  }
  
  func start() {
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
  }
  
  func stop() {
    locationManager.stopUpdatingLocation()
    locationManager.stopUpdatingHeading()
  }
}

extension LocationProvider: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    
    switch manager.authorizationStatus {
    case .authorizedWhenInUse:
      print("authorizedWhenInUse")
    default:
      #warning("Add alert")
      print("No authorization")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      self.location = location
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    heading = newHeading
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("error \(error)")
  }
}
