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
    let group = PBXGroup(children: [],
                         sourceTree: .group,
                         name: named)
    let reference = objects.generateReference(group, named)
    objects.addObject(group, reference: reference)
    parent.children.append(reference)
    
    return group
  }
  
  // MARK: Frameworks
  
  func findReference(_ named: String, parent: PBXGroup) -> String? {
    for child in parent.children {
      if let fileRef = self.objects.fileReferences.getReference(child), fileRef.name == named {
        return child
      }
    }
    return nil
  }
  
  func addFramework(_ named: String, in group: PBXGroup, path: Path) -> String {
    let fullPath = path + named

    let fileRef =  PBXFileReference(sourceTree: .group,
                                    name: named,
                                    lastKnownFileType: "wrapper.framework",
                                    path: fullPath.string)
    
    let reference = objects.generateReference(fileRef, named)
    
    objects.addObject(fileRef, reference: reference)
    group.children.append(reference)
    
    return reference
  }
  
  // MARK: build files
  
  func findBuildFile(for fileReference: String) -> String? {
    for (key, value) in objects.buildFiles where value.fileRef == fileReference {
      return key
    }
    return nil
  }
  
  func addBuildFile(for file: String) -> String {
    let buildFile = PBXBuildFile(fileRef: file)
    let reference = objects.generateReference(buildFile, file)
    
    objects.addObject(buildFile, reference: reference)

    return reference
  }
  
  // MARK: Run scripts
  
  func findShellScript(_ named: String, in target: PBXNativeTarget) -> PBXShellScriptBuildPhase? {
    return target.buildPhases
      .flatMap { self.objects.shellScriptBuildPhases.getReference($0) }
      .first { $0.name == named }
  }
  
  func addShellScript(_ named: String, content: String, in target: PBXNativeTarget) -> PBXShellScriptBuildPhase {
    let scriptPhase = PBXShellScriptBuildPhase(name: named,
                                               shellScript: content)
    let reference = objects.generateReference(scriptPhase, named)
    
    objects.addObject(scriptPhase, reference: reference)
    target.buildPhases.append(reference)
    return scriptPhase
  }
  
  // MARK: Build phases
  
  func findFrameworkPhase(in target: PBXNativeTarget) -> PBXFrameworksBuildPhase? {
    return target.buildPhases
      .flatMap { self.objects.frameworksBuildPhases[$0] }
      .first
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
