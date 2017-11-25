//
//  Project.swift
//  LibrarianCore
//
//  Created by Alex Faizullov on 11/25/17.
//

import Foundation

class Project {
  var name: String
  var targets: [Target]
  
  func resolveDependencies(for target: Target) -> [Dependency] {
    return target.dependencies
  }
  
  func resolveAllDependencies() -> Set<Dependency> {
    let flattenedDependencies = targets
      .map { self.resolveDependencies(for: $0) }
      .flatMap { $0 }
    return Set(flattenedDependencies)
  }
  
  func target(_ name: String) -> Target? {
    return targets.first { $0.name == name }
  }
  
  init(name: String,
       targets: [Target]) {
    self.name = name
    self.targets = targets
  }
}
