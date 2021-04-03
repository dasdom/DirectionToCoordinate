//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import MapKit
import Combine

class DirectionViewController: UIViewController {

  let coordinate: CLLocationCoordinate2D
  let hideDirectionAndDistance: Bool
  let locationProvider = LocationProvider()
  private var locationSubscription: AnyCancellable?
  private var headingSubscription: AnyCancellable?
  private var location: CLLocation?
  private var distanceFormatter: MKDistanceFormatter = {
    let formatter = MKDistanceFormatter()
    formatter.unitStyle = MKDistanceFormatter.DistanceUnitStyle.default
    return formatter
  }()
  private var contentView: DirectionView {
    return view as! DirectionView
  }
  
  init(coordinate: CLLocationCoordinate2D, hideDirectionAndDistance: Bool = false) {
    
    self.coordinate = coordinate
    self.hideDirectionAndDistance = hideDirectionAndDistance
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  override func loadView() {
    let contentView = DirectionView(frame: .zero, hideDirectionAndDistance: hideDirectionAndDistance)
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
    
    contentView.mapView.isRotateEnabled = !hideDirectionAndDistance
  }
  
  func updateUI(for location: CLLocation?) {
    
    self.location = location
    
    if let location = location {
      let mapView = contentView.mapView
      let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
      let distance = location.distance(from: otherLocation)
      contentView.label.text = distanceFormatter.string(fromDistance: distance)
      
      let mid = coordinate.center(to: location.coordinate)
      let shownMeters = max(1000, 1.2 * distance)
      let region = MKCoordinateRegion(center: mid, latitudinalMeters: shownMeters, longitudinalMeters: shownMeters)
      mapView.setRegion(region, animated: false)
      
      mapView.removeAnnotations(mapView.annotations)
      
      mapView.addAnnotation(Annotation(coordinate: location.coordinate))
      mapView.addAnnotation(Annotation(coordinate: coordinate))
    }
  }
  
  func updateUI(for heading: CLHeading?) {
    if let heading = heading {
      let rotation = deg2rad(bearing() - heading.magneticHeading)
      contentView.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
      contentView.mapView.camera.heading = heading.magneticHeading
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
