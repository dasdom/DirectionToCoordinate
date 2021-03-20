//  Created by Dominik Hauser on 14/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import MapKit
import Combine

protocol SendViewControllerDelegate {
  func send(_ viewController: UIViewController, coordinate: CLLocationCoordinate2D)
}

class SendViewController: UIViewController {

  let delegate: SendViewControllerDelegate
  let locationProvider = LocationProvider()
  var coordinate: CLLocationCoordinate2D?
  private var subscription: AnyCancellable?
  var contentView: SendView {
    return view as! SendView
  }
  
  init(delegate: SendViewControllerDelegate) {
    
    self.delegate = delegate
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  override func loadView() {
    let contentView = SendView()
    contentView.sendButton.addTarget(self, action: #selector(send(_:)), for: .touchUpInside)
    view = contentView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    subscription = locationProvider.$location
      .sink(receiveValue: updateUI)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    locationProvider.start()
  }
  
  func updateUI(for location: CLLocation?) {
    if let location = location {
      self.contentView.label.text = String(format: "%.5lf  %.5lf", location.coordinate.latitude, location.coordinate.longitude)
      self.contentView.setNeedsLayout()
      
      self.coordinate = location.coordinate
      
      let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
      self.contentView.mapView.setRegion(region, animated: true)
    }
  }
  
  @objc func send(_ sender: UIButton) {
    if let coordinate = coordinate {
      delegate.send(self, coordinate: coordinate)
    }
  }
}
