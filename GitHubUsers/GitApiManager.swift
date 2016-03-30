//
//  GitApiManager.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit

class GitApiManager {
  
  var baseURL: String {
    return "https://api.github.com/users"
  }
  
  func loadUserWithParams(since: Int, pageSize: Int = 15, completion: (result: NSData?, error: NSError?) -> Void) {
    let url = self.constractUrlWithParams(since, pageSize: pageSize)
    let request = NSURLRequest(URL:url)
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
    let sem = dispatch_semaphore_create(0)
    
    let session = NSURLSession.sharedSession()
    session.dataTaskWithRequest(request) { (data, response, error) -> Void in
      completion(result: data, error: error)
      dispatch_semaphore_signal(sem)
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      }.resume()
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
  }
  
  func constractUrlWithParams(since: Int, pageSize: Int) -> NSURL {
    return NSURL(string: "\(self.baseURL)?per_page=\(pageSize)&since=\(since)")!
  }
  
}