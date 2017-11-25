//
//  Dependency.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 11/25/17.
//

import Foundation

public enum Dependency: Hashable {
  case carthage(String)
  
  internal var asString: String {
    switch self {
    case let .carthage(name):
      return name
    }
  }
  
 public var hashValue: Int {
    switch self {
    case let .carthage(name):
      return name.hashValue
    }
  }
  
  public static func ==(lhs: Dependency, rhs: Dependency) -> Bool {
    switch (lhs, rhs) {
    case let (.carthage(leftName), .carthage(rightName)):
      return leftName == rightName
    }
  }
}
