//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
  
  @State var address: String = ""
  @State var error: Error?
  @EnvironmentObject private var locationProvider: LocationProvider
  let announcer = Announcer()
  let distanceFormatter: MKDistanceFormatter = {
    let formatter = MKDistanceFormatter()
    formatter.unitStyle = MKDistanceFormatter.DistanceUnitStyle.default
    return formatter
  }()
  
  var rotationAngle: Double {
    let angleInt = Int(locationProvider.angle)
    announcer.announce(angleInt: angleInt, address: address, distance: locationProvider.distance)
    return locationProvider.angle
  }
  
  var body: some View {
    VStack {
      VStack {
        TextField("Put in an address or a city.", text: $address, onCommit: {
          locationProvider.address = address
        })
        .multilineTextAlignment(.center)
        
        if let coordinate = locationProvider.addressLocation?.coordinate, abs(coordinate.latitude) > 0.001, abs(coordinate.longitude) > 0.001 {
          Text("latitude: \(coordinate.latitude)\nlongitude: \(coordinate.longitude)")
            .font(.footnote)
            .multilineTextAlignment(.center)
            .foregroundColor(Color(UIColor.secondaryLabel))
        }
      }
      
      VStack {
        Image(systemName: "location.north.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .rotationEffect(Angle(degrees: rotationAngle))
          .frame(height: 150)
          .accessibilityHidden(true)
          .padding()
        
        if let error = error {
          Text(verbatim: "\(error.localizedDescription)")
            .padding()
        } else if locationProvider.distance > 0 {
          Text(distanceFormatter.string(fromDistance: locationProvider.distance))
            .font(.headline)
            .padding()
        }
      }
      
    }
    .padding()
    .onAppear(perform: {
      locationProvider.start()
    })
    .alert(isPresented: $locationProvider.wrongAuthorization) {
      Alert(title: Text("Not authorized"),
            message: Text("Open settings and authorize."),
            dismissButton: .default(Text("Settings"), action: {
              UIApplication.shared.open(
                URL(string: UIApplication.openSettingsURLString)!)
            }))
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
