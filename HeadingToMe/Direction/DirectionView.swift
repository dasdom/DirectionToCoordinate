//  Created by Dominik Hauser on 19/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit

class DirectionView: UIView {

  let label: UILabel
  let imageView: UIImageView
  
  override init(frame: CGRect) {
    
    label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Missing"
    
    imageView = UIImageView(image: UIImage(systemName: "arrow.up"))
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    super.init(frame: frame)
    
    backgroundColor = .white
    
    addSubview(label)
    addSubview(imageView)
    
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
      
      imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      imageView.widthAnchor.constraint(equalToConstant: 100),
      imageView.heightAnchor.constraint(equalToConstant: 100),
    ])
  }
  
  required init?(coder: NSCoder) { fatalError() }
}
