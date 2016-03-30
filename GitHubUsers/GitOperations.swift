//
//  GitOperations.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit
import ImageIO


class PendingOperations {
  lazy var downloadsInProgress = [NSIndexPath:NSOperation]()
  lazy var downloadQueue:NSOperationQueue = {
    var queue = NSOperationQueue()
    queue.name = "Download queue"
    return queue
  }()
  
  lazy var thumbnailInProgress = [NSIndexPath:NSOperation]()
  lazy var thumbnailQueue:NSOperationQueue = {
    var queue = NSOperationQueue()
    queue.name = "Thumbnail queue"
    return queue
  }()
}


class ImageDownloader: NSOperation {
  let gitUser: GitUser
  init(gitUser: GitUser) {
    self.gitUser = gitUser
  }
  override func main() {
    if self.cancelled {
      return
    }
  
    let url = NSURL(string: self.gitUser.avatarURL!)!
    let imageData = NSData(contentsOfURL:url)
    
    if self.cancelled {
      return
    }
    if imageData?.length > 0 {
      self.gitUser.avatar = UIImage(data:imageData!)
      self.gitUser.state = .Downloaded
    } else {
      self.gitUser.state = .Failed
      self.gitUser.avatar = UIImage(named: "Failed")
    }
  }
}

class ThumbnailCreation: NSOperation {
  let gitUser: GitUser
  
  init(gitUser: GitUser) {
    self.gitUser = gitUser
  }
  
  override func main () {
    if self.cancelled {
      return
    }
    
    if self.gitUser.state != .Downloaded {
      return
    }
    
    if let thumbnailImage = self.createThumbnail(self.gitUser.avatar!) {
      self.gitUser.thumbnail = thumbnailImage
      self.gitUser.state = .ThumbnailReady
    }
  }
  
  func createThumbnail(image: UIImage) -> UIImage? {
    let options: [NSString: NSObject] = [
      kCGImageSourceThumbnailMaxPixelSize: 100,
      kCGImageSourceCreateThumbnailFromImageAlways: true
    ]
    let imageSource = CGImageSourceCreateWithData(UIImagePNGRepresentation(image)!, nil)
    let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource!, 0, options).flatMap { UIImage(CGImage: $0) }
    return scaledImage
  }
}
