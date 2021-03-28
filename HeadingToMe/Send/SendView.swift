//  Created by Dominik Hauser on 14/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import MapKit

class SendView: UIView {

  let mapView: MKMapView
  let label: UILabel
  let sendButton: UIButton
  
  override init(frame: CGRect) {
    
    mapView = MKMapView()
    mapView.showsUserLocation = true
    mapView.layer.cornerRadius = 5
    mapView.clipsToBounds = true
    
    label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = .center
    label.font = .preferredFont(forTextStyle: .footnote)
    label.textColor = UIColor.secondaryLabel
    
    sendButton = UIButton()
    sendButton.setTitle("Send", for: .normal)
    sendButton.setTitleColor(.blue, for: .normal)
    
    let stackView = UIStackView(arrangedSubviews: [mapView, label, sendButton])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 4
    
    super.init(frame: frame)
    
//    backgroundColor = .white
    
    addSubview(stackView)
    
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    
    let bottomConstraint = stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
    bottomConstraint.priority = UILayoutPriority(rawValue: 999)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
      bottomConstraint,
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
    ])
  }
  
  required init?(coder: NSCoder) { fatalError() }
}
