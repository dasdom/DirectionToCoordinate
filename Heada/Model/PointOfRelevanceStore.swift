//  Created by Dominik Hauser on 05.11.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import Foundation
import Combine

class PointOfRelevanceStore: ObservableObject {

  @Published var points: [PointOfRelevance] = []
  private let url = URL.documentsDirectory.appending(path: "points.json", directoryHint: .notDirectory)

  init() {
    loadPoints()
  }

  func loadPoints() {
    do {
      let data = try Data(contentsOf: url)
      points = try JSONDecoder().decode([PointOfRelevance].self, from: data)
    } catch {
      print("error: \(error)")
    }
  }

  func savePoints() {
    do {
      let data = try JSONEncoder().encode(points)
      try data.write(to: url)
    } catch {
      print("error: \(error)")
    }
  }

  func add(_ point: PointOfRelevance) {
    points.append(point)
    savePoints()
  }

  func remove(_ point: PointOfRelevance) {
    points.removeAll(where: { $0.id == point.id })
    savePoints()
  }
}
