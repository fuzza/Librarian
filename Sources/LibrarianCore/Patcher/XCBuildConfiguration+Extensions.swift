
//
//  XCBuildConfiguration+extensions.swift
//  LibrarianPackageDescription
//
//  Created by Alex Fayzullov on 11/30/17.
//

import Foundation
import xcproj

extension XCBuildConfiguration {
  enum Keys: String {
    case frameworkSearchPaths = "FRAMEWORK_SEARCH_PATHS"
  }
  
  var frameworkSearchPaths: [String] {
    get {
      if let path = buildSettings[Keys.frameworkSearchPaths.rawValue] as? String {
        return [path]
      } else if let paths = buildSettings[Keys.frameworkSearchPaths.rawValue] as? [String] {
        return paths
      }
      return []
    }
    set(paths) {
      buildSettings[Keys.frameworkSearchPaths.rawValue] = paths
    }
  }
}
