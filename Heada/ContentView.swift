//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
  
  @State var address: String = ""
  @State var coordinate: CLLocationCoordinate2D? = nil
  @State var error: Error?
  @State var angleOfLastAnnouncement: Int = 0
  @EnvironmentObject private var locationProvider: LocationProvider
  
  var location: CLLocation? {
    guard let coordinate = coordinate else {
      return nil
    }
    return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }
  var bearing: Double {
    guard let coordinate = coordinate,
          let myCoordinate = locationProvider.location?.coordinate else {
      return 0
    }
    return myCoordinate.bearing(to: coordinate)
  }
  var distance: Double {
    guard let myLocation = locationProvider.location,
          let location = location else {
      return 0
    }
    let distance = myLocation.distance(from: location)
    return distance
  }
  var rotationAngle: Double {
    let angle = bearing - (locationProvider.heading?.magneticHeading ?? 0)
    let angleInt = Int(angle)
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
    return angle
  }
  
  var body: some View {
    VStack {
      VStack {
        TextField("Put in an address or a city.", text: $address, onCommit: {
          CLGeocoder().geocodeAddressString(address) { placementMarks, error in
            if let placementMark = placementMarks?.first, let location = placementMark.location {
              
              coordinate = location.coordinate
            }
          }
        })
        .multilineTextAlignment(.center)
        
        if let coordinate = coordinate, abs(coordinate.latitude) > 0.001, abs(coordinate.longitude) > 0.001 {
          Text("\(coordinate.latitude)  \(coordinate.longitude)")
            .font(.footnote)
            .foregroundColor(Color(UIColor.secondaryLabel))
        }
      }
      
      VStack {
        Image(systemName: "location.north.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .rotationEffect(Angle(degrees: rotationAngle))
          .frame(height: 150)
          .padding()
        
        if let error = error {
          Text("\(error.localizedDescription)")
            .padding()
        } else if distance > 0 {
          Text(String(format: "%.3lf km", distance/1000))
            .font(.headline)
            .padding()
        }
      }
      
    }
    .padding()
    .accessibilityHidden(true)
    .onAppear(perform: {
      locationProvider.start()
    })
  }
}

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-annotations-in-a-map-view
extension CLLocationCoordinate2D: Identifiable {
  public var id: String {
    "\(latitude)-\(longitude)"
  }
}

struct ContentView_Previews: PreviewProvider {
  
  static var locationProvider: LocationProvider = {
    let locationProvider = LocationProvider()
    return locationProvider
  }()
  
  static var previews: some View {
    ContentView()
      .environmentObject(locationProvider)
  }
}
