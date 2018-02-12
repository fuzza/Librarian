//
//  CopyLibrariesScript.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 2/12/18.
//

import Foundation
import xcproj

class CopyLibrariesScript: BaseStep, Runnable {
  let fileRef: ObjectReference<PBXFileReference>
  let target: PBXNativeTarget
  
  required init(pbxproj: PBXProj,
                fileRef: ObjectReference<PBXFileReference>,
                target: PBXNativeTarget) {
    self.target = target
    self.fileRef = fileRef
    super.init(pbxproj: pbxproj)
  }
  
  func run() throws -> ObjectReference<PBXFileReference> {
    let scriptRef = scriptPhaseRef()
    let script = scriptRef.object
    
    let inputPath = "$(SRCROOT)/Carthage/Build/iOS/\(fileRef.object.name!)"
    if !script.inputPaths.contains(inputPath) {
      script.inputPaths.append(inputPath)
    }
    
    let outputPath = "$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/\(fileRef.object.name!)"
    if !script.outputPaths.contains(outputPath) {
      script.outputPaths.append(outputPath)
    }
    
    return fileRef
  }
  
  func scriptPhaseRef() -> ObjectReference<PBXShellScriptBuildPhase> {
    let scriptName = "\(target.name)_Librarian"
    
    let existingScriptPhase = pbxproj.objects.shellScriptBuildPhases.objectReferences.first {
      $0.object.name == scriptName && target.buildPhases.contains($0.reference)
    }
    
    if let phase = existingScriptPhase {
      return phase
    }
    
    let scriptPhase = PBXShellScriptBuildPhase(name: scriptName,
                                               shellScript: "/usr/local/bin/carthage copy-frameworks")
    
    let reference = pbxproj.objects.generateReference(scriptPhase, scriptName)
    pbxproj.objects.addObject(scriptPhase, reference: reference)
    
    target.buildPhases.append(reference)
    return ObjectReference(reference: reference, object: scriptPhase)
  }
}
