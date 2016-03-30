//
//  GitUsers.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit

class GitUsersDataSource {
   var users: [GitUser]
  
  init() {
    self.users = Array<GitUser>()
  }
}