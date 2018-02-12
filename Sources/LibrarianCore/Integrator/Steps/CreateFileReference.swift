//
//  CreateFileReference.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 2/12/18.
//

import Foundation
import xcproj
import PathKit

class CreateFileReference: BaseStep, Runnable {
  let groupToBeAddedTo: PBXGroup
  let sourcePath: Path
  let dependency: Dependency
  
  required init(pbxproj: PBXProj,
                group: PBXGroup,
                sourcePath: Path,
                dependency: Dependency) {
    self.groupToBeAddedTo = group
    self.sourcePath = sourcePath
    self.dependency = dependency
    super.init(pbxproj: pbxproj)
  }
  
  func run() throws -> ObjectReference<PBXFileReference> {
    let carthageFolder = sourcePath + "Carthage/Build/iOS"
    let path = carthageFolder + dependency.asString
    return try pbxproj.objects.addFile(at: path, toGroup: groupToBeAddedTo, sourceTree: .sourceRoot, sourceRoot: sourcePath)
  }
}
