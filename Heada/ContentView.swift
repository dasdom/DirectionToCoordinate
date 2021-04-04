//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
  
  @State var address: String = ""
  @State var error: Error?
  @State var interfaceOrientation: UIInterfaceOrientation = .portrait
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
    
    let angle: Double
    switch interfaceOrientation {
    case .landscapeLeft:
      angle = locationProvider.angle + 90
    case .landscapeRight:
      angle = locationProvider.angle - 90
    case .portraitUpsideDown:
      angle = locationProvider.angle - 180
    default:
      angle = locationProvider.angle
    }
    return angle
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
      self.interfaceOrientation = scene.interfaceOrientation
      print("self.interfaceOrientation: \(self.interfaceOrientation.rawValue)")
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
