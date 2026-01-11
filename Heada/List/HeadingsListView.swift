//  Created by Dominik Hauser on 05.11.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SwiftUI
import MapKit

struct HeadingsListView: View {

  @EnvironmentObject private var locationProvider: LocationProvider
  @State var showsInput = false
  @State var showsLegalInfo = false
  @State var selectedPoint: PointOfRelevance?
  let pointsOfRelevanceStore = PointOfRelevanceStore()
  private let distanceFormatter: MKDistanceFormatter = {
    let formatter = MKDistanceFormatter()
    formatter.unitStyle = MKDistanceFormatter.DistanceUnitStyle.default
    return formatter
  }()

  var body: some View {
    NavigationSplitView {
      if pointsOfRelevanceStore.points.isEmpty {
        ContentUnavailableView {
          Text("No places")
        } actions: {
          Button("Add place") {
            showsInput = true
          }
        }
      } else {
        List(pointsOfRelevanceStore.points, selection: $selectedPoint) { point in
          NavigationLink(value: point) {
            HeadingView(locationProvider: locationProvider, point: point, distanceFormatter: distanceFormatter)
              .swipeActions {
                Button(action: {
                  pointsOfRelevanceStore.remove(point)
                }) {
                  Label("Delete", systemImage: "trash")
                }
              }
          }
        }
//        .onChange(of: selectedPoint, { oldValue, newValue in
//          print("newValue: \(newValue)")
//        })
        .toolbar(content: {
          ToolbarItem(placement: .topBarTrailing) {
            Button("Add", systemImage: "plus", role: nil) {
              showsInput = true
            }
          }
          ToolbarItem(placement: .topBarLeading) {
            Button("Legal") {
              showsLegalInfo = true
            }
          }
        })
        .navigationTitle("Distances")
        .sheet(isPresented: $showsInput, content: {
          PointInputView(pointsStore: pointsOfRelevanceStore)
        })
        .sheet(isPresented: $showsLegalInfo, content: {
          LegalInfoView()
        })
        .onAppear {
          locationProvider.start()
        }
        .onDisappear {
          locationProvider.stop()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
          setHeadingOrientation()
        }
      }
    } detail: {
//      Text("\(selectedPoint)")
      if let selectedPoint {
        PointDetailView(point: selectedPoint)
      }
    }
  }

  private func setHeadingOrientation() {
    let deviceOrientation = UIDevice.current.orientation
#warning("Use extension on CLDeviceOritentation to make that safer")
    if let clDeviceOrientation = CLDeviceOrientation(rawValue: Int32(deviceOrientation.rawValue)) {
      self.locationProvider.set(headingOrientation: clDeviceOrientation)
    }
  }
}

struct HeadingsListView_Previews: PreviewProvider {
  static var previews: some View {
    HeadingsListView()
  }
}

