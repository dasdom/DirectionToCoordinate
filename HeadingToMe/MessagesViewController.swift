//  Created by Dominik Hauser on 20/03/2021.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import Messages
import CoreLocation

class MessagesViewController: MSMessagesAppViewController {
  
  var mainController: UIViewController?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  // MARK: - Conversation Handling
  
  override func willBecomeActive(with conversation: MSConversation) {
    super.willBecomeActive(with: conversation)
    
    presentViewController(for: conversation, with: presentationStyle)
  }
  
  override func didResignActive(with conversation: MSConversation) {
    // Called when the extension is about to move from the active to inactive state.
    // This will happen when the user dismisses the extension, changes to a different
    // conversation or quits Messages.
    
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough state information to restore your extension to its current state
    // in case it is terminated later.
  }
  
  override func didReceive(_ message: MSMessage, conversation: MSConversation) {
    // Called when a message arrives that was generated by another instance of this
    // extension on a remote device.
    
    // Use this method to trigger UI updates in response to the message.
  }
  
  override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
    // Called when the user taps the send button.
  }
  
  override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
    // Called when the user deletes the message without sending it.
    
    // Use this to clean up state related to the deleted message.
  }
  
  override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
    // Called before the extension transitions to a new presentation style.
    
    // Use this method to prepare for the change in presentation style.
  }
  
  override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
    // Called after the extension transitions to a new presentation style.
    
    // Use this method to finalize any behaviors associated with the change in presentation style.
  }
  
  private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
    removeAllChildViewControllers()
    
    let controller: UIViewController
    
    if let path = conversation.selectedMessage?.url?.path, false == path.isEmpty {
      let components = path.components(separatedBy: ":")
      if components.count > 1, let latitude = Double(components[0]), let longitude = Double(components[1]) {
        
        let hideDirectionAndDistance: Bool
        if let senderId = conversation.selectedMessage?.senderParticipantIdentifier,
           !conversation.remoteParticipantIdentifiers.contains(senderId) {
          
          hideDirectionAndDistance = true
        } else {
          hideDirectionAndDistance = false
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let directionController = DirectionViewController(coordinate: coordinate, hideDirectionAndDistance: hideDirectionAndDistance)
//        let directionController = DirectionViewController(coordinate: coordinate)
        directionController.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expand(_:))))
        controller = directionController
      } else {
        controller = UIViewController()
        controller.view.backgroundColor = .red
      }
    } else {
      let startController = SendViewController(delegate: self)
      controller = startController
    }
    
    mainController = controller
    
    addChild(controller)
    
    controller.view.frame = view.bounds
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(controller.view)
    
    NSLayoutConstraint.activate([
      controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
      controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
      controller.view.topAnchor.constraint(equalTo: view.topAnchor),
      controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    
    controller.didMove(toParent: self)
  }
  
  private func removeAllChildViewControllers() {
    for child in children {
      child.willMove(toParent: nil)
      child.view.removeFromSuperview()
      child.removeFromParent()
    }
  }
  
  fileprivate func composeMessage(coordinate: CLLocationCoordinate2D, caption: String, image: UIImage?, session: MSSession? = nil) -> MSMessage {
    
    let templateLayout = MSMessageTemplateLayout()
    templateLayout.image = image
    templateLayout.caption = caption
    
    let message = MSMessage(session: session ?? MSSession())
    //        let message = MSMessage()
    message.url = URL(string: "\(coordinate.latitude):\(coordinate.longitude)")

//    message.layout = templateLayout
    let liveLayout = MSMessageLiveLayout(alternateLayout: templateLayout)
    message.layout = liveLayout

    return message
  }
  
  override func contentSizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: size.width, height: 150)
  }
  
  @objc func expand(_ sender: UITapGestureRecognizer) {
    requestPresentationStyle(.expanded)
  }
}

extension MessagesViewController: SendViewControllerDelegate {
  func send(_ viewController: UIViewController, coordinate: CLLocationCoordinate2D) {
    
    guard let conversation = activeConversation else { fatalError("Expected a conversation") }
    
//    let image = viewController.screenshot()
    let image: UIImage? = nil
    
    let message = composeMessage(coordinate: coordinate, caption: "I'm here", image: image, session: conversation.selectedMessage?.session)
    
    conversation.insert(message) { error in
      if let error = error {
        print(error)
      }
      
    }
  
    dismiss()
  }
}
