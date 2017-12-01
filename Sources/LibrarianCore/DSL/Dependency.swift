//
//  Dependency.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 11/25/17.
//

import Foundation

public enum Dependency: AutoHashable, AutoEquatable, Decodable {
  case carthage(String)
  
  var asString: String {
    switch self {
    case let .carthage(name):
      return name + ".framework"
    }
  }

  // MARK: Decodable
  public init(from decoder: Decoder) throws {
    let name = try decoder.singleValueContainer().decode(String.self)
    self = .carthage(name)
  }
  
  
}
