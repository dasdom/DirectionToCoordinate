//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
  
  @State private var address: String = ""
  @EnvironmentObject private var locationProvider: LocationProvider
  private let announcer = Announcer()
  @ViewBuilder private var addressOrCityField: some View {
    TextField("Put in an address or a city.", text: $address, onEditingChanged: { startEditing in
      if startEditing {
        locationProvider.reset()
      }
    }, onCommit: {
      locationProvider.address = address
    })
    .multilineTextAlignment(.center)
  }
  private var notAuthorizedAlert: Alert {
    Alert(title: Text("Not authorized"),
          message: Text("Open settings and authorize."),
          dismissButton: .default(Text("Settings"), action: {
            UIApplication.shared.open(
              URL(string: UIApplication.openSettingsURLString)!)
          }))
  }
  
  private var rotationAngle: Double {
    let angle = locationProvider.angle
    announcer.announce(angle: angle, address: address, distance: locationProvider.distance)
    return angle
  }
  
  var body: some View {
    VStack {
      addressOrCityField
      
      LatLongText(coordinate: locationProvider.addressLocation?.coordinate)
      
      DirectionDistance(angle: rotationAngle, error: locationProvider.error, distance: locationProvider.distance)
      
      RoutingButton(locationProvider: locationProvider)
    }
    .padding()
    .onAppear(perform: locationProvider.start)
    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
      setHeadingOrientation()
    }
    .alert(isPresented: $locationProvider.wrongAuthorization) {
      notAuthorizedAlert
    }
  }
  
  private func setHeadingOrientation() {
    if let scene = UIApplication.shared.windows.first?.windowScene,
       let deviceOrientation = CLDeviceOrientation(interfaceOrientation: scene.interfaceOrientation) {
      
      self.locationProvider.set(headingOrientation: deviceOrientation)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  
  static var locationProvider: LocationProvider = LocationProvider()
  
  static var previews: some View {
    ContentView()
      .environmentObject(locationProvider)
  }
}
