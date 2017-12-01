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
  case rootGroupNotFound
  case configurationsNotFound(String)
}

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
  
  // MARK: Frameworks
  
  func findReference(_ named: String, parent: PBXGroup) -> PBXFileReference? {
    return parent.children
      .flatMap { self.objects.fileReferences.getReference($0) }
      .first { $0.name == named }
  }
  
  func addFramework(_ named: String, in group: PBXGroup, path: Path) -> PBXFileReference {
    let fullPath = path + named
    
    let uuid = generateUUID(for: PBXFileReference.self)
    
    let reference =  PBXFileReference(reference: uuid,
                                      sourceTree: .group,
                                      name: named,
                                      lastKnownFileType: "wrapper.framework",
                                      path: fullPath.string)
    
    objects.addObject(reference)
    group.children.append(uuid)
    
    return reference
  }
  
  // MARK: build files
  
  func findBuildFile(for fileReference: PBXFileReference) -> PBXBuildFile? {
    return objects.buildFiles.values
      .first { $0.fileRef == fileReference.reference }
  }
  
  func addBuildFile(for file: PBXFileReference) -> PBXBuildFile {
    let uuid = generateUUID(for: PBXBuildFile.self)
    
    let buildFile = PBXBuildFile(reference: uuid, fileRef: file.reference)
    objects.addObject(buildFile)
    
    return buildFile
  }
  
  // MARK: Run scripts
  
  func findShellScript(_ named: String, in target: PBXNativeTarget) -> PBXShellScriptBuildPhase? {
    return target.buildPhases
      .flatMap { self.objects.shellScriptBuildPhases.getReference($0) }
      .first { $0.name == named }
  }
  
  func addShellScript(_ named: String, content: String, in target: PBXNativeTarget) -> PBXShellScriptBuildPhase {
    let reference = generateUUID(for: PBXShellScriptBuildPhase.self)
    let scriptPhase = PBXShellScriptBuildPhase(reference: reference,
                                               name: named,
                                               shellScript: content)
    
    objects.addObject(scriptPhase)
    target.buildPhases.append(reference)
    return scriptPhase
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
