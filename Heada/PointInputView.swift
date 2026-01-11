//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct PointInputView: View {

  let pointsStore: PointOfRelevanceStore
  @State private var address: String = ""
  @EnvironmentObject private var locationProvider: LocationProvider
  @Environment(\.dismiss) private var dismiss
  private let announcer = Announcer()
  private var notAuthorizedAlert: Alert {
    Alert(title: Text("Not authorized"),
          message: Text("Open settings and authorize."),
          dismissButton: .default(Text("Settings"), action: openSettings))
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
      
//      RoutingButton(locationProvider: locationProvider)

      Button("Save") {
        if let address = locationProvider.address, let coordinate = locationProvider.addressLocation?.coordinate {
          pointsStore.add(
            PointOfRelevance(name: address,
                             address: address,
                             coordinate: Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude),
                             timezone: locationProvider.timeZone)
          )
          dismiss()
        }
      }
      .disabled(nil == locationProvider.addressLocation)
    }
    .padding()
    .onAppear(perform: {
      locationProvider.start()
      locationProvider.reset()
    })
    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
      setHeadingOrientation()
    }
    .alert(isPresented: $locationProvider.wrongAuthorization) {
      notAuthorizedAlert
    }
  }
  
  private func setHeadingOrientation() {
    let deviceOrientation = UIDevice.current.orientation
    #warning("Use extension on CLDeviceOritentation to make that safer")
    if let clDeviceOrientation = CLDeviceOrientation(rawValue: Int32(deviceOrientation.rawValue)) {
      self.locationProvider.set(headingOrientation: clDeviceOrientation)
    }
  }

  private func openSettings() {
    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
  }

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
}

//struct ContentView_Previews: PreviewProvider {
//  
//  static var locationProvider: LocationProvider = LocationProvider()
//  
//  static var previews: some View {
//    PointInputView()
//      .environmentObject(locationProvider)
//  }
//}
