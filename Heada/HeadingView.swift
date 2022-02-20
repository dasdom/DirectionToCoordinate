//  Created by Dominik Hauser on 05.11.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct HeadingView: View {

  let location: PointOfRelevance
  let heading: CLLocationDirection?
  let deviceCoordinate: CLLocation?
  let distanceFormatter: MKDistanceFormatter

  private var angle: Double {
    return LocationProvider.angle(coordinate: location.coordinate,
                                  heading: heading,
                                  deviceCoordinate: deviceCoordinate)
  }
  private var distance: CLLocationDistance {
    guard let deviceCoordinate = deviceCoordinate else {
      return 0
    }
    return location.clLocation.distance(from: deviceCoordinate)
  }

  var body: some View {
    HStack {
        Image(systemName: "location.north.fill")
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .rotationEffect(Angle(degrees: angle))
          .frame(height: 60)
        .padding()


      VStack {
        Text(location.name)
          .font(.title)
        Text(distanceFormatter.string(fromDistance: distance))
          .font(.body)
      }
    }
  }
}

struct HeadingView_Previews: PreviewProvider {
  static let distanceFormatter: MKDistanceFormatter = {
    let formatter = MKDistanceFormatter()
    formatter.unitStyle = MKDistanceFormatter.DistanceUnitStyle.default
    return formatter
  }()

  static var previews: some View {
    HeadingView(location: PointOfRelevance(name: "Name",
                                   address: "Address",
                                   coordinate: Coordinate(latitude: 1,
                                                          longitude: 2)),
                heading: 30,
    deviceCoordinate: CLLocation(latitude: 20, longitude: 50),
    distanceFormatter: distanceFormatter)
      .previewLayout(.sizeThatFits)
  }
}
