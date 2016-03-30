//
//  GitUser.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit

enum PhotoState {
  case New, Downloaded, ThumbnailReady, Failed
}

class GitUser {
  var id: Int?
  var login: String?
  var htmlURL: String?
  var avatarURL: String?
  var thumbnail: UIImage? = UIImage(named: "NoImage")
  var avatar: UIImage?
  var state = PhotoState.New

  
  init(dict: NSDictionary) {
    self.avatarURL = dict["avatar_url"] as? String
    self.login = dict["login"] as? String
    self.id = dict["id"] as? Int
    self.htmlURL = dict["html_url"] as? String
  }
}
