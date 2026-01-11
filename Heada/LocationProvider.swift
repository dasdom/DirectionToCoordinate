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
  @Published var timeZone: TimeZone?
  @Published var error: Error?
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
            self.timeZone = placementMark.timeZone
          } else {
            self.error = error
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
    
    $location.sink(receiveValue: updateLocation).store(in: &cancellables)
    $addressLocation.sink(receiveValue: updateAddressLocation).store(in: &cancellables)
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
  
  func set(headingOrientation: CLDeviceOrientation) {
    locationManager.headingOrientation = headingOrientation
  }
  
  func reset() {
    addressLocation = nil
    distance = 0
  }
}

extension LocationProvider: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    
    switch manager.authorizationStatus {
    case .authorizedWhenInUse:
      wrongAuthorization = false
      print("authorizedWhenInUse")
    default:
      wrongAuthorization = true
      print("No authorization")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    location = locations.last
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    heading = newHeading
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("error \(error)")
  }
  
  private func updateLocation(location: CLLocation?) {
    updateAngle(heading: heading)
    updateDistance(location: location, addressLocation: addressLocation)
  }
  
  private func updateAddressLocation(addressLocation: CLLocation?) {
    updateAngle(heading: heading)
    updateDistance(location: location, addressLocation: addressLocation)
  }
  
  private func update(heading: CLHeading?) {
    updateAngle(heading: heading)
    updateDistance(location: location, addressLocation: addressLocation)
  }
  
  func updateAngle(heading: CLHeading?) {
    if let coordinate = addressLocation?.coordinate,
          let myCoordinate = location?.coordinate,
          let heading = heading {
      
      let bearing = myCoordinate.bearing(to: coordinate)
      angle = bearing - heading.magneticHeading
//    } else {
//      print("missing value \(addressLocation?.coordinate), \(location?.coordinate), \(heading)")
    }
  }
  
  func updateDistance(location: CLLocation?, addressLocation: CLLocation?) {
    if let location = location,
       let addressLocation = addressLocation {
      
      distance = location.distance(from: addressLocation)
    }
  }

  func angle(coordinate: Coordinate) -> Double {

    guard let deviceCoordinate = location else {
      return 0
    }
    guard let heading = heading else {
      #if targetEnvironment(simulator)
      let clCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
      let bearing = deviceCoordinate.coordinate.bearing(to: clCoordinate)
      return bearing
      #else
            return 0
      #endif
          }

    let clCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    let bearing = deviceCoordinate.coordinate.bearing(to: clCoordinate)
    return bearing - heading.magneticHeading
  }
}
