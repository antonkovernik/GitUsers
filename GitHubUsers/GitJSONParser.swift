//
//  GitJSONParser.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit

class GitJSONParser {
  static func parse(data:NSData) -> [GitUser] {
    var users = Array<GitUser>()
    do {
      let array = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [NSDictionary]
      for object in array  {
        let gitUser = GitUser(dict: object)
        users.append(gitUser)
      }
    } catch let error as NSError {
      print("Error: \(error.userInfo)")
    }
    return users
  }
}