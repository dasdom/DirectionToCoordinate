//  Created by Dominik Hauser on 14/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import MapKit
import Combine

protocol SendViewControllerDelegate {
  func send(_ viewController: UIViewController, coordinate: CLLocationCoordinate2D, image: UIImage?)
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
      var options = MKMapSnapshotter.Options()
      options.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
      var snapshotter = MKMapSnapshotter(options: options)
      snapshotter.start { [weak self] snapshot, error in

        let alert = UIAlertController(title: "Sure?", message: "Do you really want to compose a message with your coordinates?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Compose", style: .default, handler: { [weak self] action in
          guard let self = self else { return }
          self.delegate.send(self, coordinate: coordinate, image: snapshot?.image)
        }))
        
        self?.present(alert, animated: true)
      }

    }
  }
}
