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
  @Published var addressLocation: CLLocation?
  @Published var angle: Double = 0
  @Published var heading: CLHeading? = nil
  @Published var distance: Double = 0
  
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
      self.updateAngle()
      self.updateDistance()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    heading = newHeading
    self.updateAngle()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("error \(error)")
  }
  
  func updateAngle() {
    if let coordinate = addressLocation?.coordinate,
          let myCoordinate = location?.coordinate,
          let heading = heading {
      
      let bearing = myCoordinate.bearing(to: coordinate)
      angle = bearing - heading.magneticHeading
    }
  }
  
  func updateDistance() {
    if let location = location,
       let addressLocation = addressLocation {
      
      distance = location.distance(from: addressLocation)
    }
  }
  
  func locate(address: String) {
    CLGeocoder().geocodeAddressString(address) { placementMarks, error in
      if let placementMark = placementMarks?.first, let location = placementMark.location {
        self.addressLocation = location
        self.updateAngle()
        self.updateDistance()
      }
    }
  }
}
