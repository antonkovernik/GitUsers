
//
//  AvatarPreviewViewController.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit

class AvatarPreviewViewController: UIViewController {

  @IBOutlet var imageView: UIImageView!
  
  var image: UIImage! = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.imageView.image = self.image
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AvatarPreviewViewController.actionClose(_:))))
  }
  
  func actionClose(tap: UITapGestureRecognizer) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
