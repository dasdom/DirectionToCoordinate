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
  var distance: Int {
    if let myLocation = locationProvider.location {
      return Int(myLocation.distance(from: location))
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
        Triangle()
          .rotation(Angle(degrees: bearing - (locationProvider.heading?.magneticHeading ?? 0)))
          .frame(width: 80, height: 100)
          .padding()
        if let error = error {
          Text("\(error.localizedDescription)")
            .padding()
        } else {
          Text("\(distance/1000) km")
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
  
  // https://www.hackingwithswift.com/books/ios-swiftui/paths-vs-shapes-in-swiftui
  struct Triangle: Shape {
      func path(in rect: CGRect) -> Path {
          var path = Path()

          path.move(to: CGPoint(x: rect.midX, y: rect.minY))
          path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
          path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
          path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

          return path
      }
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
