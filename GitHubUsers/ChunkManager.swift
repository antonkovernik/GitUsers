//
//  ChunkManager.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit

class ChunkManager {
  
  var gitDataProvider: GitDataProvider
  var lastUserIndex: Int
  var dataSource: GitUsersDataSource
  var chunkSize: Int  {
    return 15
  }

  init(dataSource: GitUsersDataSource) {
    self.lastUserIndex = dataSource.users.count
    self.gitDataProvider = GitDataProvider()
    self.dataSource = dataSource
  }
  
  func loadChunkWithCompletion(completion: () -> Void) {
    self.gitDataProvider.loadUsers(lastUserIndex, amount: self.chunkSize) { [weak self] (users) -> (Void) in
      self?.dataSource.users.appendContentsOf(users)
      self?.lastUserIndex += users.last!.id!
      completion()
    }
  }
}
