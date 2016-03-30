//
//  ViewController.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet var tableView: UITableView!
  
  let transition = Animator()

  let dataSource: GitUsersDataSource!
  let dataManager: DataManager!
  
  var selectedImageView: UIImageView?
  var startFrame: CGRect?
  
  required init?(coder aDecoder: NSCoder) {
    self.dataSource = GitUsersDataSource()
    self.dataManager = DataManager(dataSource: self.dataSource)
    super.init(coder: aDecoder)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.loadDataAndReloadTable()
  }
  
  func loadDataAndReloadTable() {
    self.dataManager.loadDataIfNeeded {
      dispatch_async(dispatch_get_main_queue(), {
        self.tableView.reloadData()
      })
    }
  }
}

extension ViewController: UITableViewDelegate {
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
    let y = scrollView.contentOffset.y + scrollView.contentInset.top
    let threshold = max(0.0, scrollView.contentSize.height - visibleHeight) * 0.75
    if y > threshold {
      self.loadDataAndReloadTable()
    }
  }
  
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    self.dataManager.suspendAllOperations()
  }
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      self.dataManager.loadImagesForOnscreenCells(self.tableView)
      self.dataManager.resumeAllOperations()
    }
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    self.dataManager.loadImagesForOnscreenCells(self.tableView)
    self.dataManager.resumeAllOperations()
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let gitUser = self.dataSource.users[indexPath.row]
    if gitUser.state != .ThumbnailReady {
      return
    }
    let preview = storyboard!.instantiateViewControllerWithIdentifier("avatarPreviewViewController") as! AvatarPreviewViewController
    preview.image = gitUser.avatar
    preview.transitioningDelegate = self
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    self.startFrame = cell?.imageView?.frame
    self.selectedImageView = cell?.imageView
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    presentViewController(preview, animated: true, completion: nil)

  }
}

extension ViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataSource.users.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("defaultCell")!
    let gitUser = self.dataSource.users[indexPath.row]
    cell.textLabel?.text = gitUser.login
    cell.detailTextLabel?.text = gitUser.htmlURL
    cell.imageView?.image = gitUser.thumbnail
    if cell.accessoryView == nil {
      let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
      cell.accessoryView = indicator
    }
    let indicator = cell.accessoryView as! UIActivityIndicatorView

    switch (gitUser.state) {
    case .ThumbnailReady:
      indicator.stopAnimating()
    case .Failed:
      indicator.stopAnimating()
      cell.textLabel?.text = "Failed to load"
    case .New, .Downloaded:
      indicator.startAnimating()
      if (!tableView.dragging && !tableView.decelerating) {
        self.dataManager.startOperationsForPhotoRecord(gitUser, indexPath: indexPath, tableView: tableView)
      }
    }

    return cell
  }
  
}

extension ViewController: UIViewControllerTransitioningDelegate {
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    transition.originFrame = selectedImageView!.convertRect(startFrame!, toView: nil)
    transition.presenting = true
    
    return transition
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.presenting = false
    return transition
  }

}

