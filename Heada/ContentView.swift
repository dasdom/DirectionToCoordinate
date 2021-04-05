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
  
  var rotationAngle: Double {
    let angleInt = Int(locationProvider.angle)
    announcer.announce(angleInt: angleInt, address: address, distance: locationProvider.distance)
    
    return locationProvider.angle
  }
  
  var body: some View {
    VStack {
      VStack {
        TextField("Put in an address or a city.", text: $address, onEditingChanged: { startEditing in
          if startEditing {
            locationProvider.addressLocation = nil
            locationProvider.distance = 0
          }
        }, onCommit: {
          locationProvider.address = address
        })
        .multilineTextAlignment(.center)
        
        LatLongText(coordinate: locationProvider.addressLocation?.coordinate)
      }
      
      DirectionDistance(angle: rotationAngle, error: error, distance: locationProvider.distance)
          
      if locationProvider.distance > 0 {
        Button(action: {
          openMapWithDiretions()
        }, label: {
          Image(systemName: "arrow.triangle.turn.up.right.diamond")
        })
        .font(.title)
      }
    }
    .padding()
    .onAppear(perform: {
      locationProvider.start()
    })
    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
      guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
      if let deviceOrientation = CLDeviceOrientation(rawValue: Int32(scene.interfaceOrientation.rawValue)) {
        self.locationProvider.set(headingOrientation: deviceOrientation)
      }
    }
    .alert(isPresented: $locationProvider.wrongAuthorization) {
      Alert(title: Text("Not authorized"),
            message: Text("Open settings and authorize."),
            dismissButton: .default(Text("Settings"), action: {
              UIApplication.shared.open(
                URL(string: UIApplication.openSettingsURLString)!)
            }))
    }
  }
  
  func openMapWithDiretions() {
    if let coordinate = locationProvider.addressLocation?.coordinate,
       let address = locationProvider.address {
      let place = MKPlacemark(coordinate: coordinate)
      let destination = MKMapItem(placemark: place)
      destination.name = address
      let options = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDefault]
      MKMapItem.openMaps(with: [destination], launchOptions: options)
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
