//  Created by Dominik Hauser on 10.01.26.
//  Copyright © 2026 dasdom. All rights reserved.
//


import SwiftUI
import MapKit

struct PointDetailView: View {
  let point: PointOfRelevance
  @State var lookAroundManager = LookAroundManager()
  var center: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
  }

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      Map(bounds: MapCameraBounds(centerCoordinateBounds: MKCoordinateRegion(center: center, latitudinalMeters: 2000, longitudinalMeters: 2000), minimumDistance: 20_000, maximumDistance: 20_000_000)) {
        Marker(point.name, coordinate: center)
      }

      if let lookAroundScene = lookAroundManager.lookAroundScene {
        LookAroundPreview(initialScene: lookAroundScene, allowsNavigation: true)
          .clipShape(RoundedRectangle(cornerRadius: 25))
          .frame(width: 300, height: 200)
          .padding()
      }
    }
    .task {
      await lookAroundManager.loadPreview(coordinate: center)
    }
  }
}

//#Preview {
//  PointDetailView(point: PointOfRelevance(name: "San Francisco", address: "Foo", coordinate: Coordinate(latitude: 37.779379, longitude: -122.418433), timezone: nil))
//}
