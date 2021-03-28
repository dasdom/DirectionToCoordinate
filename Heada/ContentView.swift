//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
  
  @State var address: String = ""
  @State var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
  @State var error: Error?
  @State var lastAnnouncedAngle: Int = 0
//  @State var region: MKCoordinateRegion = MKCoordinateRegion()
//  @State var annotationItems: [CLLocationCoordinate2D] = []
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
      let distance = myLocation.distance(from: location)
      return distance
    } else {
      return 0
    }
  }
  var rotationAngle: Double {
    let angle = bearing - (locationProvider.heading?.magneticHeading ?? 0)
    let angleInt = Int(angle)
    print("\(angleInt), \(angleInt % 10 == 0)")
    if angleInt % 10 == 0 {
      print("angle: \(angleInt)")
      UIAccessibility.post(notification: .announcement, argument: "angle: \(angleInt)")
    }
    return angle
  }
  
  var body: some View {
//    VStack {
//      Map(coordinateRegion: $region, interactionModes: .all, annotationItems: annotationItems, annotationContent: { item -> MapMarker in
//        let color: Color?
//        if item.id == self.coordinate.id {
//          color = .red
//        } else {
//          color = .gray
//        }
//        return MapMarker(coordinate: item, tint: color)
//      })
      
      VStack {
        VStack {
          TextField("Put in an address or a city.", text: $address, onCommit: {
            CLGeocoder().geocodeAddressString(address) { placementMarks, error in
              if let placementMark = placementMarks?.first, let location = placementMark.location {
                
                coordinate = location.coordinate
                
//                updateAnnotations()
              }
            }
          })
          .multilineTextAlignment(.center)
          
          if abs(coordinate.latitude) > 0.001, abs(coordinate.longitude) > 0.001 {
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
          } else {
            Text(String(format: "%.3lf km", distance/1000))
              .font(.headline)
              .padding()
          }
        }
        
      }
      .padding()
      //      .background(Color(UIColor.systemBackground).opacity(0.7))
      .onAppear(perform: {
        locationProvider.start()
//        updateAnnotations()
      })
//    }
  }
  
//  func updateAnnotations() {
//    if let myCoordinate = locationProvider.location?.coordinate {
//      annotationItems = [coordinate]
//      annotationItems.append(myCoordinate)
//
//      let mid = myCoordinate.center(to: coordinate)
//      region = MKCoordinateRegion(center: mid, latitudinalMeters: 1.2 * distance, longitudinalMeters: 1.2 * distance)
//    }
//  }
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
