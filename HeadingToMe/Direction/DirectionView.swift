//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import MapKit

class DirectionView: UIView {

  let mapView: MKMapView
  let imageView: UIImageView
  let label: UILabel
  
  init(frame: CGRect, hideDirectionAndDistance: Bool) {
        
    mapView = MKMapView()
    mapView.translatesAutoresizingMaskIntoConstraints = false
    mapView.alpha = 0.5
    
    imageView = UIImageView(image: UIImage(systemName: "location.north.fill"))
    imageView.contentMode = .scaleAspectFit
    
    label = UILabel()
    label.text = "Missing"
    label.textAlignment = .center
    label.font = .preferredFont(forTextStyle: .headline)
    
    let stackView = UIStackView(arrangedSubviews: [imageView, label])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.spacing = 10
    stackView.isHidden = hideDirectionAndDistance
    
    super.init(frame: frame)
    
//    backgroundColor = .white
    
    addSubview(mapView)
    addSubview(stackView)
    
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: topAnchor),
      mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
      mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
      mapView.trailingAnchor.constraint(equalTo: trailingAnchor),

      stackView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
      
      imageView.widthAnchor.constraint(equalToConstant: 100),
      imageView.heightAnchor.constraint(equalToConstant: 100),
    ])
  }
  
  required init?(coder: NSCoder) { fatalError() }
}
