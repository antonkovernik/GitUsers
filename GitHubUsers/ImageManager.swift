//
//  ImageManager.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit

class ImageManager {
  let dataSource: GitUsersDataSource
  let pendingOperations = PendingOperations()
  
  init(dataSource: GitUsersDataSource) {
    self.dataSource = dataSource
  }
  
  func startOperationsForPhotoRecord(gitUser: GitUser, indexPath: NSIndexPath, tableView: UITableView) {
    switch (gitUser.state) {
    case .New:
      startDownloadForRecord(gitUser, indexPath: indexPath, tableView: tableView)
    case .Downloaded:
      createThumbnailForUser(gitUser, indexPath: indexPath, tableView: tableView)
    default: break
    }
  }
  
  func suspendAllOperations () {
    pendingOperations.downloadQueue.suspended = true
    pendingOperations.thumbnailQueue.suspended = true
  }
  
  func resumeAllOperations () {
    pendingOperations.downloadQueue.suspended = false
    pendingOperations.thumbnailQueue.suspended = false
  }
  
  func loadImagesForOnscreenCells (tableView: UITableView) {
    if let pathsArray = tableView.indexPathsForVisibleRows {
      var allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
      allPendingOperations.unionInPlace(pendingOperations.thumbnailInProgress.keys)
      
      var toBeCancelled = allPendingOperations
      let visiblePaths = Set(pathsArray)
      toBeCancelled.subtractInPlace(visiblePaths)
      
      var toBeStarted = visiblePaths
      toBeStarted.subtractInPlace(allPendingOperations)
      
      for indexPath in toBeCancelled {
        if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
          pendingDownload.cancel()
        }
        pendingOperations.downloadsInProgress.removeValueForKey(indexPath)
        if let pendingFiltration = pendingOperations.thumbnailInProgress[indexPath] {
          pendingFiltration.cancel()
        }
        pendingOperations.thumbnailInProgress.removeValueForKey(indexPath)
      }
      
      for indexPath in toBeStarted {
        let indexPath = indexPath as NSIndexPath
        let recordToProcess = self.dataSource.users[indexPath.row]
        startOperationsForPhotoRecord(recordToProcess, indexPath: indexPath, tableView: tableView)
      }
    }
  }
  
  func startDownloadForRecord(gitUser: GitUser, indexPath: NSIndexPath, tableView: UITableView){
    if let _ = pendingOperations.downloadsInProgress[indexPath] {
      return
    }
    
    let downloader = ImageDownloader(gitUser: gitUser)
    
    downloader.completionBlock = {
      if downloader.cancelled {
        return
      }
      dispatch_async(dispatch_get_main_queue(), {
        self.pendingOperations.downloadsInProgress.removeValueForKey(indexPath)
        self.createThumbnailForUser(gitUser, indexPath: indexPath, tableView: tableView)
      })
    }
    pendingOperations.downloadsInProgress[indexPath] = downloader
    pendingOperations.downloadQueue.addOperation(downloader)
  }
  
  func createThumbnailForUser(gitUser: GitUser, indexPath: NSIndexPath, tableView: UITableView){
    if let _ = pendingOperations.thumbnailInProgress[indexPath] {
      return
    }
    
    let thumbailer = ThumbnailCreation(gitUser: gitUser)
    thumbailer.completionBlock = {
      if thumbailer.cancelled {
        return
      }
      dispatch_async(dispatch_get_main_queue(), {
        self.pendingOperations.thumbnailInProgress.removeValueForKey(indexPath)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
          let indicator = cell.accessoryView as! UIActivityIndicatorView
          indicator.stopAnimating()
          cell.imageView?.image = gitUser.thumbnail
        }
      })
    }
    pendingOperations.thumbnailInProgress[indexPath] = thumbailer
    pendingOperations.thumbnailQueue.addOperation(thumbailer)
  }

}
