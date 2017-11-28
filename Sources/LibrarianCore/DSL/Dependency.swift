//
//  Dependency.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 11/25/17.
//

import Foundation

public enum Dependency: AutoHashable, AutoEquatable {
  case carthage(String)
  
  internal var asString: String {
    switch self {
    case let .carthage(name):
      return name
    }
  }
}
