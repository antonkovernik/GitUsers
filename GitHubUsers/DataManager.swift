//
//  DataManager.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit


class DataManager {
  
  var dataSource: GitUsersDataSource
  var chunkManager: ChunkManager
  var imageManager: ImageManager
  
  var maxUsersCount: Int {
    return 100
  }

  let queue = dispatch_queue_create("chunkQueue", DISPATCH_QUEUE_SERIAL)
  
  init(dataSource: GitUsersDataSource) {
    self.dataSource = dataSource
    self.chunkManager = ChunkManager(dataSource: dataSource)
    self.imageManager = ImageManager(dataSource: dataSource)
  }
  
  func loadDataIfNeeded(completion: () -> Void) {
    if dataSource.users.count < self.maxUsersCount {
      dispatch_async(queue, { 
        self.chunkManager.loadChunkWithCompletion(completion)
      })
    }
  }

  func startOperationsForPhotoRecord(gitUser: GitUser, indexPath: NSIndexPath, tableView: UITableView) {
    self.imageManager.startOperationsForPhotoRecord(gitUser, indexPath: indexPath, tableView: tableView)
  }
  func suspendAllOperations() {
    self.imageManager.suspendAllOperations()
  }
  
  func loadImagesForOnscreenCells(tableView: UITableView) {
    self.imageManager.loadImagesForOnscreenCells(tableView)
  }
  
  func resumeAllOperations() {
    self.imageManager.resumeAllOperations()
  }
}
