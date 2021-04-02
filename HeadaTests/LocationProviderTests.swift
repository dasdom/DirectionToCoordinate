//  Created by Dominik Hauser on 02/04/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import XCTest
@testable import Heada
import CoreLocation

class LocationProviderTests: XCTestCase {
  
  var sut: LocationProvider!
  var locationManager: CLLocationManager!
  
  override func setUpWithError() throws {
    locationManager = CLLocationManager()
    sut = LocationProvider(locationManager: locationManager)
  }
  
  override func tearDownWithError() throws {
    sut = nil
  }
  
  func test_locationUpdate_updatesAngle() throws {
    sut.locationManager(locationManager, didUpdateHeading: CLHeading())
    sut.addressLocation = CLLocation(latitude: 1, longitude: 2)
    var resultAngle: Double? = nil
    _ = sut.$angle.dropFirst().sink { angle in
      resultAngle = angle
    }
    
    let location = CLLocation(latitude: 3, longitude: 4)
    sut.locationManager(locationManager, didUpdateLocations: [location])
    
    let unwrappedResult = try XCTUnwrap(resultAngle)
    XCTAssertEqual(unwrappedResult, 10)
  }
}
