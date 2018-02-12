//
//  CreateBuildFileReference.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 2/12/18.
//

import Foundation
import xcproj

class CreateBuildFileReference: BaseStep, Runnable {
  enum Errors: Error {
    case noFrameworkBuildPhase(target: PBXNativeTarget)
  }
  
  let target: PBXNativeTarget
  let fileRef: ObjectReference<PBXFileReference>
  
  init(pbxproj: PBXProj,
       target: PBXNativeTarget,
       fileRef: ObjectReference<PBXFileReference>) {
    self.target = target
    self.fileRef = fileRef
    super.init(pbxproj: pbxproj)
  }
  
  func run() throws -> ObjectReference<PBXBuildFile> {
    let frameworkPhaseRef = pbxproj.objects.frameworksBuildPhases.objectReferences.first {
      target.buildPhases.contains($0.reference)
    }
    
    guard let frameworkBuildPhase = frameworkPhaseRef?.object else {
      throw Errors.noFrameworkBuildPhase(target: target)
    }
    
    let buildFile = findOrCreateBuildFile()
    
    if !frameworkBuildPhase.files.contains(buildFile.reference) {
      frameworkBuildPhase.files.append(buildFile.reference)
    }
    return buildFile
  }
  
  func findOrCreateBuildFile() -> ObjectReference<PBXBuildFile> {
    let existingOptionalBuildFile = pbxproj.objects.buildFiles.objectReferences.first {
      $0.object.fileRef == fileRef.reference
    }
    
    if let existingBuildFile = existingOptionalBuildFile {
      return existingBuildFile
    }
    
    let buildFile = PBXBuildFile(fileRef: fileRef.reference)
    let reference = pbxproj.objects.generateReference(buildFile, fileRef.reference)
    pbxproj.objects.addObject(buildFile, reference: reference)
    return ObjectReference(reference: reference, object: buildFile)
  }
}
