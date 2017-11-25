//
//  Target.swift
//  LibrarianCore
//
//  Created by Alex Faizullov on 11/25/17.
//

import Foundation

public struct Target {
  internal var name: String
  internal var dependencies: [Dependency]
  
  public init(name: String,
              dependencies: [Dependency]) {
    self.name = name
    self.dependencies = dependencies
  }
}
