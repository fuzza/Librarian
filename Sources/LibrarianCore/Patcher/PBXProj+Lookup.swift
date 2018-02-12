//
//  ProjectPatcher.swift
//  LibrarianCore
//
//  Created by Alex Fayzullov on 11/30/17.
//

import Foundation
import xcproj
import PathKit

enum LookupErrors: Error, AutoEquatable {
  case rootProjectNotFound
  case configurationsNotFound(String)
}

extension PBXProj {
  
  // MARK: Configurations
  
  func projectConfigs() throws -> [XCBuildConfiguration] {
    let project = try root()
    return try configurations(of: project)
  }
  
  // MARK: Helpers
  
  internal func root() throws -> PBXProject {
    let rootObjectUid = rootObject
    guard let project = objects.projects.getReference(rootObjectUid) else {
      throw LookupErrors.rootProjectNotFound
    }
    return project
  }
  
  internal func configurations(of project: PBXProject) throws -> [XCBuildConfiguration] {
    let configListUid = project.buildConfigurationList
    
    guard let configs = self.objects.configurationLists.getReference(configListUid) else {
      throw LookupErrors.configurationsNotFound(project.name)
    }
    
    return configs.buildConfigurations
      .flatMap { self.objects.buildConfigurations.getReference($0) }
  }
}
