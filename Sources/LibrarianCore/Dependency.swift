//
//  Dependency.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 11/25/17.
//

import Foundation

enum Dependency: Hashable {
  case carthage(String)
  
  var asString: String {
    switch self {
    case let .carthage(name):
      return name
    }
  }
  
  var hashValue: Int {
    switch self {
    case let .carthage(name):
      return name.hashValue
    }
  }
  
  static func ==(lhs: Dependency, rhs: Dependency) -> Bool {
    switch (lhs, rhs) {
    case let (.carthage(leftName), .carthage(rightName)):
      return leftName == rightName
    }
  }
}
