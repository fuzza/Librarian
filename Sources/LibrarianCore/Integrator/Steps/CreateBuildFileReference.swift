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
    
    let buildFile: ObjectReference<PBXBuildFile>
    let buildFiles = findOrCreateBuildFiles()
    
    if buildFiles.count > 1 {
        buildFile = deduplicate(buildFiles: buildFiles)
    } else {
        buildFile = buildFiles[0]
    }
    
    if !frameworkBuildPhase.files.contains(buildFile.reference) {
      frameworkBuildPhase.files.append(buildFile.reference)
    }
    return buildFile
  }
  
  func deduplicate(buildFiles: [ObjectReference<PBXBuildFile>]) -> ObjectReference<PBXBuildFile> {
    let filesToDrop = buildFiles.dropFirst()
    let fileToKeep = buildFiles[0]
    
    filesToDrop.forEach { buildFileRef in
        pbxproj.objects.buildFiles.removeValue(forKey: buildFileRef.reference)
    }
    
    pbxproj.objects.frameworksBuildPhases.values.forEach { phase in
        phase.files = phase.files.filter { !filesToDrop.map { $0.reference }.contains($0) }
    }
    
    return fileToKeep
  }
    
  func findOrCreateBuildFiles() -> [ObjectReference<PBXBuildFile>] {
    let existingBuildFiles = pbxproj.objects.buildFiles.objectReferences.filter {
      $0.object.fileRef == fileRef.reference
    }
    
    if !existingBuildFiles.isEmpty {
      return existingBuildFiles
    }
    
    let buildFile = PBXBuildFile(fileRef: fileRef.reference)
    let reference = pbxproj.objects.generateReference(buildFile, fileRef.reference)
    pbxproj.objects.addObject(buildFile, reference: reference)
    return [ObjectReference(reference: reference, object: buildFile)]
  }
}
