//  Created by Dominik Hauser on 05.11.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct HeadingView: View {
  let locationProvider: LocationProvider
  let point: PointOfRelevance
  let distanceFormatter: MKDistanceFormatter
  @State var dateFormatter: DateFormatter?

  private var angle: Double {
    return locationProvider.angle(coordinate: point.coordinate)
  }
  private var distance: CLLocationDistance {
    guard let deviceCoordinate = locationProvider.location else {
      return 0
    }
    return point.clLocation.distance(from: deviceCoordinate)
  }

  var body: some View {
    HStack {
        Image(systemName: "arrow.up")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .rotationEffect(Angle(degrees: angle))
          .frame(height: 60)
        .padding()


      VStack(alignment: .leading) {
        Text(point.name)
          .font(.title2)
        Text(distanceFormatter.string(fromDistance: distance))
          .font(.body)
        if let dateFormatter {
          Text("Local Time: \(dateFormatter.string(from: Date()))")
        }
      }
    }
    .onAppear {
      if let timezone = point.timezone {
        dateFormatter = DateFormatter()
        dateFormatter?.dateFormat = "HH:mm"
        dateFormatter?.timeZone = timezone
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
    HeadingView(locationProvider: LocationProvider(),
      point: PointOfRelevance(name: "Name",
                                   address: "Address",
                                   coordinate: Coordinate(latitude: 1,
                                                          longitude: 2), timezone: nil),
    distanceFormatter: distanceFormatter)
      .previewLayout(.sizeThatFits)
  }
}
