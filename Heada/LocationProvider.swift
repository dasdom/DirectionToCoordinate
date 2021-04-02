//  Created by Dominik Hauser on 14/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import CoreLocation
import Combine

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
  @Published var wrongAuthorization: Bool = false
  private var cancellables = Set<AnyCancellable>()
  
  var address: String? = nil {
    didSet {
      if let address = address {
        CLGeocoder().geocodeAddressString(address) { placementMarks, error in
          if let placementMark = placementMarks?.first, let location = placementMark.location {
            self.addressLocation = location
          }
        }
      }
    }
  }
  
  init(locationManager: CLLocationManager = CLLocationManager()) {
    
    self.locationManager = locationManager
    
    super.init()
    
    locationManager.requestWhenInUseAuthorization()
    locationManager.delegate = self
    
    $location.sink(receiveValue: update).store(in: &cancellables)
    $addressLocation.sink(receiveValue: update).store(in: &cancellables)
    $heading.sink(receiveValue: update).store(in: &cancellables)
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
      wrongAuthorization = true
      print("No authorization")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.location = locations.last
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    heading = newHeading
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("error \(error)")
  }
  
  private func update(location: CLLocation?) {
    self.updateAngle()
    self.updateDistance()
  }
  
  private func update(heading: CLHeading?) {
    self.updateAngle()
    self.updateDistance()
  }
  
  func updateAngle() {
    if let coordinate = addressLocation?.coordinate,
          let myCoordinate = location?.coordinate,
          let heading = heading {
      
      let bearing = myCoordinate.bearing(to: coordinate)
      angle = bearing - heading.magneticHeading
//    } else {
//      print("missing value \(addressLocation?.coordinate), \(location?.coordinate), \(heading)")
    }
  }
  
  func updateDistance() {
    if let location = location,
       let addressLocation = addressLocation {
      
      distance = location.distance(from: addressLocation)
    }
  }
}