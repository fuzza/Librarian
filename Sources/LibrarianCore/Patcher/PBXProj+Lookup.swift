//
//  ProjectPatcher.swift
//  LibrarianCore
//
//  Created by Alex Fayzullov on 11/30/17.
//

import Foundation
import xcproj

enum LookupErrors: Error, AutoEquatable {
  case rootProjectNotFound
  case rootGroupNotFound
  case configurationsNotFound(String)
}

// MARK: Project configuration lookup

extension PBXProj {
  
  // MARK: Configurations
  func projectConfigs() throws -> [XCBuildConfiguration] {
    let project = try root()
    return try configurations(of: project)
  }
  
  
  // MARK: Groups
  func rootGroup() throws -> PBXGroup {
    let project = try root()
    guard let group = objects.groups.getReference(project.mainGroup) else {
      throw LookupErrors.rootProjectNotFound
    }
    return group
  }
  
  func findGroup(_ named: String, parent: PBXGroup) -> PBXGroup? {
    return parent.children
      .flatMap { self.objects.groups.getReference($0) }
      .first { $0.path == named || $0.name == named }
  }
  
  func createGroup(_ named: String, addTo parent: PBXGroup) -> PBXGroup {
    let groupUid = generateUUID(for: PBXGroup.self)
    let group = PBXGroup(reference: groupUid,
                         children: [],
                         sourceTree: .group,
                         name: named)
    
    objects.addObject(group)
    parent.children.append(groupUid)
    
    return group
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
