//
//  GitDataProvider.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit

class GitDataProvider {
  var gitApiManager: GitApiManager
  
  init() {
    self.gitApiManager = GitApiManager()
  }
  
  func loadUsers(since: Int, amount: Int, completion: (users: [GitUser])->(Void))  {
    gitApiManager.loadUserWithParams(since, pageSize: amount) { (result, error) in
      if (error == nil) {
        let users = GitJSONParser.parse(result!)
        completion(users: users)
      }
    }
  }
}
