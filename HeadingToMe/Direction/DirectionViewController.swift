//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import CoreLocation
import Combine

class DirectionViewController: UIViewController {

  let coordinate: CLLocationCoordinate2D
  let locationProvider = LocationProvider()
  private var locationSubscription: AnyCancellable?
  private var headingSubscription: AnyCancellable?
  private var location: CLLocation?
  private var contentView: DirectionView {
    return view as! DirectionView
  }
  
  init(coordinate: CLLocationCoordinate2D) {
    
    self.coordinate = coordinate
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  override func loadView() {
    let contentView = DirectionView()
    view = contentView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationSubscription = locationProvider.$location
      .sink(receiveValue: updateUI)
    
    headingSubscription = locationProvider.$heading
      .sink(receiveValue: updateUI)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    locationProvider.start()
  }
  
  func updateUI(for location: CLLocation?) {
    
    self.location = location
    
    if let location = location {
      let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
      let distance = location.distance(from: otherLocation)
      contentView.label.text = String(format: "%.2lf km", distance / 1000)
    }
  }
  
  func updateUI(for heading: CLHeading?) {
    if let heading = heading {
      let rotation = deg2rad(bearing() - heading.magneticHeading)
      contentView.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
    }
  }
  
  func bearing() -> Double {
    if let myCoordinate = location?.coordinate {
      return myCoordinate.bearing(to: coordinate)
    } else {
      return 0
    }
  }
}
