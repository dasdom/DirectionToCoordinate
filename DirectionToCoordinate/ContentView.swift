//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ContentView: View {

  @State var address: String = ""
  @State var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
  @State var error: Error?
  @EnvironmentObject private var locationProvider: LocationProvider

  var location: CLLocation {
    return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }
  var bearing: Double {
    if let myCoordinate = locationProvider.location?.coordinate {
      return myCoordinate.bearing(to: coordinate)
    } else {
      return 0
    }
  }
  var distance: Double {
    if let myLocation = locationProvider.location {
      return myLocation.distance(from: location)
    } else {
      return 0
    }
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
        
        if abs(coordinate.latitude) > 0.001, abs(coordinate.longitude) > 0.001 {        Text("\(coordinate.latitude)  \(coordinate.longitude)")
          .font(.footnote)
          .foregroundColor(Color(UIColor.secondaryLabel))
        }
      }
      
      VStack {
        Image(systemName: "location.north.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .rotationEffect(Angle(degrees: bearing - (locationProvider.heading?.magneticHeading ?? 0)))
          .frame(height: 100)
          .padding()
        if let error = error {
          Text("\(error.localizedDescription)")
            .padding()
        } else {
          Text(String(format: "%.2lf km", distance/1000))
            .font(.headline)
            .padding()
        }
      }
      
    }
    .padding()
    .onAppear(perform: {
      locationProvider.start()
    })
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
